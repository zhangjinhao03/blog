---
title: 【Android】Java Heap与CC算法
date: 2026-09-08 14:15:25
tags: [Android,GC]
categories: Android
series: Android虚拟机知识
top_img: /img/1400253.png
cover: /img/1400253.png
---

# ART Java Heap 内存布局与 CC GC 算法核心工作流程分析

## 一、Java Heap 内存空间详细布局

ART 虚拟机的 Java Heap 由多个内存空间(Space)组成,每个空间有不同的用途、分配策略和 GC 回收策略。以下基于 AOSP master 分支 `runtime/gc/heap.h` 源码分析。

### 1.1 Heap 整体架构图

![whiteboard_exported_image2](whiteboard_exported_image2.png)

### 1.2 各内存空间详细说明

| **空间名称**       | **类型 (SpaceType)**       | **实现类**                          | **GC****策略** | **可移动** | **用途与特点**                                               |
| :----------------- | :------------------------- | :---------------------------------- | :------------- | :--------- | :----------------------------------------------------------- |
| Boot Image Space   | kSpaceTypeImageSpace       | ImageSpace                          | NeverCollect   | 否         | 内存映射预编译的 `.art` 镜像文件,包含核心框架类(String、Class等),所有进程共享,GC时作为 Immune Space 不扫描 |
| Zygote Space       | kSpaceTypeZygoteSpace      | ZygoteSpace                         | FullCollect    | 否         | Zygote fork 前通过 `PreZygoteFork()` 从 NonMoving Space 分裂而来,所有 App 进程通过 COW 共享,仅在 Full GC 时作为 Immune Space 扫描 |
| Region Space       | kSpaceTypeRegionSpace      | RegionSpace                         | AlwaysCollect  | **是**     | CC GC 的主分配空间,分为 256KB 大小的 Region,支持 TLAB(32KB)分配,对象可在 GC 时被复制移动 |
| Non-Moving Space   | kSpaceTypeMallocSpace      | RosAllocSpace / DlMallocSpace       | AlwaysCollect  | 否         | 存放不可移动对象:Class、ArtMethod、ArtField 等 runtime 内部结构,默认容量 64MB,使用 RosAlloc 分配器 |
| Large Object Space | kSpaceTypeLargeObjectSpace | LargeObjectMapSpace / FreeListSpace | AlwaysCollect  | 否         | 存放 ≥12KB 的原始类型数组(primitive array)和大字符串,每个对象独立 mmap,不支持 TLAB |

### 1.3 RegionSpace 内部结构详解

RegionSpace 是 CC GC 最核心的内存空间,源码位于 `runtime/gc/space/region_space.h`。

![whiteboard_exported_image3](whiteboard_exported_image3.png)

**Region 状态机 (RegionState)**:

| **状态**                | **说明**                        |
| :---------------------- | :------------------------------ |
| `kRegionStateFree`      | 空闲区域,可被分配使用           |
| `kRegionStateAllocated` | 已分配区域,正常大小对象         |
| `kRegionStateLarge`     | 大对象头部区域(对象 > 256KB时)  |
| `kRegionStateLargeTail` | 大对象尾部区域(跟随 Large Head) |

**Region 类型 (RegionType)** — 仅 GC 期间有意义:

| **类型**                     | **说明**                                                     |
| :--------------------------- | :----------------------------------------------------------- |
| `kRegionTypeToSpace`         | To-Space: GC 复制的目标空间,也是新对象分配空间               |
| `kRegionTypeFromSpace`       | From-Space: 需要被疏散(evacuate)的区域,存活对象将被复制到 To-Space |
| `kRegionTypeUnevacFromSpace` | 不疏散的 From-Space: 存活率高的区域,不需要复制,原地保留      |
| `kRegionTypeNone`            | 空闲区域,不属于任何逻辑空间                                  |

### 1.4 TLAB (Thread-Local Allocation Buffer) 机制

**TLAB 关键参数**:

- `kDefaultTLABSize` = 32KB(默认 TLAB 大小)
- `kPartialTlabSize` = 16KB(TLAB 扩展粒度)
- `kUsePartialTlabs` = true
- 每个线程持有一个 TLAB,在 Region 内 bump-pointer 分配
- GC FlipThreadRoots 时回收所有线程的 TLAB

**分配路径**:

1. 线程尝试在当前 TLAB 中 bump-pointer 分配
2. TLAB 空间不足 → 申请新 TLAB (`AllocNewTlab`)
3. 从 Free Region 分配一个新 Region 给线程
4. 对象 ≥ 12KB → 直接进入 Large Object Space
5. 对象 > Region Size → Region Space 内多 Region 大对象分配

### 1.5 Heap 关键常量

| **常量**                       | **值** | **说明**                  |
| :----------------------------- | :----- | :------------------------ |
| kDefaultInitialSize            | 2 MB   | Heap 初始大小             |
| kDefaultMaximumSize            | 256 MB | Heap 最大容量             |
| kDefaultNonMovingSpaceCapacity | 64 MB  | Non-Moving Space 默认容量 |
| kRegionSize                    | 256 KB | Region 大小               |
| kDefaultLargeObjectThreshold   | 12 KB  | 进入 LOS 的对象大小阈值   |
| kDefaultTLABSize               | 32 KB  | 默认 TLAB 大小            |
| kDefaultHeapGrowthMultiplier   | 2.0    | 前台堆增长倍数            |

### 1.6 Heap 内存空间虚拟地址布局图

![whiteboard_exported_image4](whiteboard_exported_image4.png)

{% note blue 'fas fa-wand-magic-sparkles' %}
**GC** **回收策略说明**: NeverCollect 空间永远不回收(Boot Image); FullCollect 空间仅在 Full GC 时扫描(Zygote); AlwaysCollect 空间每次 GC 都参与(Region/NonMoving/LOS)。在 CC GC 中,NeverCollect 和 FullCollect 空间被标记为 Immune Space,GC 只扫描其脏卡(dirty card)中指向其他空间的引用。
{% endnote %}

## 二、CC (Concurrent Copying) GC 算法核心工作流程

CC GC 是 Android 10+ 的默认 GC 算法,实现在 `runtime/gc/collector/concurrent_copying.cc`,是一种**并发复制式**垃圾回收器,使用 **Read Barrier** 保证 to-space 不变式。

### 2.1 CC GC 总体流程图

![whiteboard_exported_image](whiteboard_exported_image.png)

### 2.2 各阶段详细分析

#### 阶段一: InitializePhase (初始化)

**执行条件**: 持有 `mutator_lock_` shared lock(Mutator 可并发运行)

**核心操作**:

1. 重置计数器: `bytes_moved_`, `objects_moved_`, `bytes_scanned_`
2. 设置 `force_evacuate_all_` — 当 GC 原因是 Explicit/CollectorTransition/ClearSoftRefs 时强制疏散所有区域
3. 调用 `BindBitmaps()`:
   1. Image Space 和 Zygote Space → 加入 `immune_spaces_`
   2. Region Space → 获取 mark bitmap,Young GC 时 Age 卡表,Full GC 时清除卡表
4. 标记 Zygote 大对象 (`MarkZygoteLargeObjects`)
5. 设置 mark stack 模式为 ThreadLocal

#### 阶段二: MarkingPhase (标记) — 仅 Full GC

{% note blue 'fas fa-wand-magic-sparkles' %}

此阶段仅在 Generational CC 的 Full GC (`!young_gen_ && !force_evacuate_all_`) 时执行。Young GC 跳过此阶段,直接通过 FlipThreadRoots 的读屏障来发现新生代存活对象。

{% endnote %}

**核心操作**:

1. 清零所有非 Free Region 的 `live_bytes_`(新分配 Region 除外)
2. 扫描 Immune Space:通过 ModUnionTable 或 CardTable 找到指向可回收空间的引用
3. 扫描 Runtime Roots: `VisitConcurrentRoots` + `VisitNonThreadRoots`
4. 捕获线程根: `CaptureThreadRootsForMarking`
5. 处理 Mark Stack 并计算各 Region 的 `live_bytes_`

#### 阶段三: FlipThreadRoots (翻转线程根) — STW 暂停

{% note red 'fas fa-bell' %}
这是 CC GC 唯一的 STW(Stop-The-World)暂停点,目标是尽量短暂(通常 < 1ms)。
{% endnote %}

![whiteboard_exported_image5](whiteboard_exported_image5.png)

**FlipThreadRoots 内部操作**:

1. 调用 `SetFromSpace()` 将 Region 标记为 FromSpace 或 UnevacFromSpace
2. 对每个线程执行 `ThreadFlipVisitor`:
   1. 设置线程的 GC Marking 状态为 true
   2. 回收线程的 TLAB (`RevokeThreadLocalBuffers`)
   3. 遍历线程根引用,将 from-space 引用更新为 to-space 引用(复制对象)
3. 设置 `is_asserting_to_space_invariant_ = true`

#### 阶段四: CopyingPhase (复制) — 并发

**核心操作**:

![whiteboard_exported_image6](whiteboard_exported_image6.png)

**并发****复制的核心机制 — Read Barrier (Baker 读屏障)**:

**Read Barrier 工作原理**:

当 Mutator 线程读取一个对象引用时:

1. 检查对象的 ReadBarrier State
2. 如果是 Gray State → 触发读屏障慢路径
3. 慢路径中调用 `Mark()` → `Copy()`:

- 在 to-space 分配新空间
- 复制对象内容
- 在原对象头部安装转发指针(forwarding pointer)
- 将新对象引用入栈(mark stack)

1. 返回 to-space 中的新引用

**To-Space 不变式**:

CC GC 保证在 GC 运行期间,所有 Mutator 看到的引用都指向 to-space 中的对象。这通过读屏障实现:

- 每次读取 heap reference 时检查
- from-space 对象被自动复制到 to-space
- 使用 CAS 安装 forwarding pointer 避免重复复制
- GC 线程和 Mutator 线程都可以执行复制

#### 阶段五: ReclaimPhase (回收)

**核心操作**:

1. `CleanupClassLoaders()` — 清理已卸载的 ClassLoader
2. `IssueEmptyCheckpoint()` — 确保所有线程都看到最新状态
3. `Sweep()` — 扫描 Non-Moving Space 的 mark bitmap,释放未标记对象
4. `SwapBitmaps()` — 交换 live/mark bitmap
5. `ClearFromSpace()` — **核心**: 清除 From-Space 的所有 Region,释放内存
6. `ReleaseFreeRegions()` — 如需释放内存给 OS (`madvise`)

#### 阶段六: FinishPhase (收尾)

**核心操作**:

1. 清除 Region Space 卡表(非 Generational CC 时)
2. 清除 inter-region-ref bitmap(Full GC 时)
3. 清理 `skipped_blocks_map_`
4. `ClearMarkedObjects()` — 清除所有 mark bit
5. `FilterModUnionCards()` — 过滤不需要的 ModUnion 卡
6. 清空 `rb_mark_bit_stack_` — 重置读屏障标记位

### 2.3 Generational CC: Young GC vs Full GC

CC GC 支持分代回收(Generational CC),通过 `use_generational_cc_` 和 `young_gen_` 控制:

![whiteboard_exported_image7](whiteboard_exported_image7.png)

| **对比项**   | **Young** **GC** | **Full** **GC**                                   |
| :----------- | :--------------- | :------------------------------------------------ |
| GcType       | kGcTypeSticky    | kGcTypePartial                                    |
| MarkingPhase | 跳过             | 执行(计算 live_bytes)                             |
| 疏散范围     | 仅新分配 Region  | 所有非 Immune Region(根据存活率决定)              |
| 卡表处理     | Age cards(老化)  | Clear cards(清除)                                 |
| 暂停时间     | 更短(扫描范围小) | 稍长(需标记全堆)                                  |
| 触发条件     | 常规内存分配触发 | Young GC 回收不足/Explicit GC/CollectorTransition |

### 2.4 Region 疏散策略 (EvacMode)

`SetFromSpace()` 根据 EvacMode 决定哪些 Region 需要疏散:

| **EvacMode**                        | **使用场景**                      | **疏散规则**                                         |
| :---------------------------------- | :-------------------------------- | :--------------------------------------------------- |
| kEvacModeNewlyAllocated             | Young GC                          | 仅疏散 `is_newly_allocated_` 的 Region               |
| kEvacModeLivePercent­NewlyAllocated | Full GC (常规)                    | 疏散新分配的 Region + live_bytes 低于阈值的旧 Region |
| kEvacModeForceAll                   | Explicit GC / CollectorTransition | 强制疏散所有非 Immune Region                         |

### 2.5 CC GC 完整时序图

![whiteboard_exported_image8](whiteboard_exported_image8.png)

### 2.6 关键数据结构关系图

![whiteboard_exported_image9](whiteboard_exported_image9.png)

## 三、总结

### Heap 内存布局要点

1. **5 大空间**: Image、Zygote、Region、NonMoving、LOS
2. **Region Space 是核心**: 256KB Region 粒度,支持 TLAB 快速分配
3. **分层** **GC** **策略**: NeverCollect → FullCollect → AlwaysCollect
4. **大对象分离**: ≥12KB 原始数组进入 LOS,避免复制开销

### CC GC 算法要点

1. **并发复制**: 通过 Read Barrier 实现 GC 与 Mutator 并发运行
2. **极短暂停**: STW 仅在 FlipThreadRoots 翻转根引用时发生(< 1ms)
3. **分代优化**: Young GC 仅扫描新分配 Region,Full GC 全堆标记
4. **智能疏散**: 根据 Region 存活率决定疏散或原地保留,减少复制量
