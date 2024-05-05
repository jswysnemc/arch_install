sed -i '/^HOOKS=(base kms udev autodetect microcode modconf keyboard keymap consolefont numlock block encrypt filesystems fsck)$/{
h
s/kms //
x
s/^/# /
G
}' test.txt
