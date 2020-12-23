import os
import psutil
import GPUtil

def byte_converter(bytes, suffix="B"):
    factor = 1024
    for unit in ["", "K", "M", "G", "T", "P"]:
        if bytes < factor:
            return f"{bytes:.0f}{unit}{suffix}"
        bytes /= factor

# run command and return output
def run_cmd(cmd):
    return os.popen(cmd).read().strip()

# return bar
def return_bar(fill=0, bar_len=10, justify=18):
    block = int(round(bar_len * fill))
    if fill > 0.75:
        bar = "[{}] {}%".format("#"*block + "-"*(bar_len-block), int(fill*100))
    elif fill > 0.5:
        bar = "[{}] {}%".format("#"*block + "-"*(bar_len-block), int(fill*100))
    else:
        bar = "[{}] {}%".format("#"*block + "-"*(bar_len-block), int(fill*100))
    return bar.ljust(justify)

def sort_process_mem():
    proc_objects = []
    for proc in psutil.process_iter():
        try:
            pinfo = proc.as_dict(attrs=['pid', 'name', 'cpu_percent'])
            pinfo['vms'] = proc.memory_info().vms / (1024 * 1024)
            proc_objects.append(pinfo)
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    proc_objects = sorted(proc_objects, key=lambda procObj: procObj['vms'], reverse=True)
    return proc_objects

def cpu_info():
    name = run_cmd("grep model /proc/cpuinfo | cut -d : -f2 | tail -1 | sed 's/\s//'")
    print("-" * 70)
    print("{:>15}: {}".format("CPU", name))
    print("-" * 70)
    core_wise = psutil.cpu_percent(percpu=True, interval=1)
    print("{:>40}".format("CPU Usage Per Core"))
    print("-" * 70)
    msg = ""
    for num in range(len(core_wise)):
        if (num+1)%4 == 0:
            msg += f"{return_bar(core_wise[num]/100, bar_len=10)}"
            print(msg)
            msg = ""
        else:
            msg += f"{return_bar(core_wise[num]/100, bar_len=10)}"
    print("-" * 70)
    print(f"Total CPU usage: {return_bar(psutil.cpu_percent()/100, bar_len=45)}")
    
    print("-" * 70)
    print("{:>15} {:>25} {:>15}".format("Process ID", "Process Name", "CPU %"))
    print("-" * 70)
    processes = sort_process_mem()[0:5]
    for process in processes:
        print("{:>13} {:>25} {:>16}".format(process['pid'], process['name'], process['cpu_percent']))
        
def mem_info():
    print("-" * 70)
    print("{:>40}".format("Memory Information"))
    print("-" * 70)
    svmem = psutil.virtual_memory()
    swap = psutil.swap_memory()
    print(f"RAM: {return_bar(svmem.percent/100, bar_len=12, justify=15)} ({byte_converter(svmem.used)}/{byte_converter(svmem.total)}) SWAP: {return_bar(swap.percent/100, bar_len=12, justify=15)} ({byte_converter(swap.used)}/{byte_converter(swap.total)})")

    root = psutil.disk_usage('/')
    home = psutil.disk_usage('/home')
    print(f"root: {return_bar(root.percent/100, bar_len=9, justify=10)} ({byte_converter(root.used)}/{byte_converter(root.total)}) home: {return_bar(home.percent/100, bar_len=9, justify=10)} ({byte_converter(home.used)}/{byte_converter(home.total)})")

def gpu_info():
    print("-" * 70)
    print("{:>40}".format("GPU Information"))
    print("-" * 70)
    gpus = GPUtil.getGPUs()
    
    for gpu in gpus:
        print(f"{gpu.name}: {return_bar(gpu.memoryUsed/gpu.memoryTotal, bar_len=12, justify=15)} ({gpu.memoryUsed}MB/{gpu.memoryTotal}MB) Temp: {gpu.temperature}°C")
    gpu_processes = run_cmd("nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader,nounits").split(",")
    gpu_processes = [p for p in gpu_processes if p.strip()]
    print("-" * 70)
    print("{:>15} {:>24} {:>20}".format("Process ID", "Process Name", "Memory (MB)"))
    print("-" * 70)
    for i in range(0, len(gpu_processes), 3):
        print("{:>13} {:>25} {:>16}".format(gpu_processes[i], gpu_processes[i+1], gpu_processes[i+2]))

if __name__ == "__main__":
    cpu_info()
    mem_info()
    gpu_info()
