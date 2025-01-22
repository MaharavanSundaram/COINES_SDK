7z a -t7z _drivers.7z -m0=lzma -mx=9 -aoa  .\_driver_files\*
copy /b 7zDP_lzma.sfx + 7zDP_lzma.cfg + _drivers.7z app_board_usb_driver.exe