echo -e "\033[32m---------------------------使用说明---------------------------
1.直接执行脚本，例如：“./dump_perfetto_v3.sh test”,10s后脚本自动
终止，会把结果保存在同级目录的result中;
--------------------------------------------------------------\033[0m"
adb shell perfetto \
  -c - --txt \
  -o /data/misc/perfetto-traces/trace \
<<EOF


data_sources: {
    config {
        name: "linux.process_stats"
        target_buffer: 1
        process_stats_config {
            scan_all_processes_on_start: true
        }
    }
}
data_sources: {
    config {
        name: "linux.sys_stats"
        sys_stats_config {
            stat_period_ms: 1000
            stat_counters: STAT_CPU_TIMES
            stat_counters: STAT_FORK_COUNT
        }
    }
}
data_sources: {
    config {
        name: "android.log"
        android_log_config {
            log_ids: LID_EVENTS
            log_ids: LID_CRASH
            log_ids: LID_KERNEL
            log_ids: LID_DEFAULT
            log_ids: LID_RADIO
            log_ids: LID_SECURITY
            log_ids: LID_STATS
            log_ids: LID_SYSTEM
        }
    }
}

# data_sources: {
#     config {
#         name: "android.surfaceflinger.frametimeline"
#     }
# }

data_sources: {
    config {
        name: "linux.ftrace"
        ftrace_config {
            symbolize_ksyms: true
            ftrace_events: "ftrace/print"
            ftrace_events: "binder/*"
            ftrace_events: "sched/sched_switch"
            ftrace_events: "power/suspend_resume"
            ftrace_events: "sched/sched_wakeup"
            ftrace_events: "sched/sched_wakeup_new"
            ftrace_events: "sched/sched_waking"
            ftrace_events: "power/cpu_frequency"
            ftrace_events: "power/cpu_idle"
            ftrace_events: "vmscan/mm_vmscan_kswapd_wake"
            ftrace_events: "vmscan/mm_vmscan_kswapd_sleep"
            ftrace_events: "vmscan/mm_vmscan_direct_reclaim_begin"
            ftrace_events: "vmscan/mm_vmscan_direct_reclaim_end"
            ftrace_events: "compaction/mm_compaction_begin"
            ftrace_events: "compaction/mm_compaction_end"
            ftrace_events: "mm_filemap_add_to_page_cache"
            ftrace_events: "mm_filemap_delete_from_page_cache"
            ftrace_events: "power/gpu_frequency"
            ftrace_events: "gpu_mem/gpu_mem_total"
            ftrace_events: "sched/sched_process_exit"
            ftrace_events: "sched/sched_process_free"
            ftrace_events: "task/task_newtask"
            ftrace_events: "task/task_rename"
            ftrace_events: "lowmemorykiller/lowmemory_kill"
            ftrace_events: "oom/oom_score_adj_update"
            ftrace_events: "sched/sched_blocked_reason"
            atrace_categories: "am"
            atrace_categories: "aidl"
            atrace_categories: "webview"
            atrace_categories: "binder_lock"
            atrace_categories: "binder_driver"
            atrace_categories: "camera"
             atrace_categories: "database"
            atrace_categories: "gfx"
            atrace_categories: "hal"
            atrace_categories: "input"
            atrace_categories: "pm"
            atrace_categories: "rs"
            atrace_categories: "res"
            atrace_categories: "rro"
            atrace_categories: "sm"
            atrace_categories: "ss"
            atrace_categories: "video"
            atrace_categories: "view"
            atrace_categories: "wm"
            atrace_categories: "dalvik"
            atrace_categories: "power"
            atrace_categories: "sched"
            atrace_apps: "*"
        }
    }
}

data_sources {
  config {
    name: "android.heapprofd"
    heapprofd_config {
      shmem_size_bytes: 8388608
      sampling_interval_bytes: 4096
      block_client: true
      process_cmdline: "system_server"
      heaps: "com.android.art"
      continuous_dump_config {
        dump_phase_ms: 0
        dump_interval_ms: 1000
      }
    }
  }
}

data_sources {
    config {
        name: "linux.perf"
        perf_event_config {
            timebase {
                frequency: 5000
                counter: HW_CPU_CYCLES
                timestamp_clock: PERF_CLOCK_MONOTONIC
            }
        }
    }
}

data_sources {
    config {
        name: "linux.perf"
        perf_event_config {
            timebase {
                frequency: 5000
                counter: HW_INSTRUCTIONS
                timestamp_clock: PERF_CLOCK_MONOTONIC
            }
        }
    }
}

#buffers: {
#   size_kb: 522240
#    fill_policy: RING_BUFFER
#}
#buffers: {
 #   size_kb: 2048
 #   fill_policy: RING_BUFFER
#}
#duration_ms: 120000
#flush_period_ms: 30000
#incremental_state_config {
 #   clear_period_ms: 5000
#}

buffers: {
    size_kb: 522240
    fill_policy: RING_BUFFER
}
buffers: {
    size_kb: 2048
    fill_policy: RING_BUFFER
}
duration_ms: 15000
write_into_file: true
file_write_period_ms: 2500
max_file_size_bytes: 2000000000
flush_period_ms: 20000
incremental_state_config {
    clear_period_ms: 5000
}
EOF
# if [ ! -d "result" ];then
#   mkdir result
# fi
out_dir=/home/zhangjinhao3/art/trace
file_path=${out_dir}/systrace_$(date +%Y%m%d%H%M%S)
if [ -n $1 ]; then
    file_path=${file_path}_$1
fi

adb pull /data/misc/perfetto-traces/trace ${file_path}

