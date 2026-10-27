import subprocess

cmd = [r"D:\Android\sdk\cmdline-tools\latest\bin\sdkmanager.bat", "--sdk_root=D:\\Android\\sdk", "--licenses"]
p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

# Send 50 'y\n's
out, err = p.communicate(input="y\n" * 50)
print(out)
if err:
    print("ERR:", err)
