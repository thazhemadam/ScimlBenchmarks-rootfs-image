# Rootfs Images

```bash
if [ -d "../rootfs-images" ]; then
    git clone git@github.com:JuliaCI/rootfs-images.git ../
fi
julia rootfs-script.jl --arch amd64
```
