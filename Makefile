a.img: boot.bin setup.bin
        rm -rf a.img
        dd if=setup.bin of=c.img conv=notrunc
        dd if=boot.bin of=a.img
setup.bin: setup.asm
        rm -f setup.bin
        nasm -f bin -o setup.bin setup.asm
boot.bin: boot.asm  $(shell ls inc/*)
        rm -rf boot.bin
        nasm -f bin -o boot.bin boot.asm