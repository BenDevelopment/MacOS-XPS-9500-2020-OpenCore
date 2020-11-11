# Dell XPS15 9500 OpenCore (MacOS)

This is an OpenCore EFI that allows you to install and boot macOS X Catalina on your Dell XPS 15 9500 (2020).

<b>OpenCore Version:</b> 0.6.3

<b>macOS Version:</b> Catalina 10.15.7

![alt text](https://github.com/BenDevelopment/MacOS-XPS-9500-2020-OpenCore/blob/main/Screenshot.png?raw=true)

---

## Functional Status

|Function / Hardware|Status|
|-|-|
|iGPU UHD630 Acceleration|Working|
|CPU Power Management|Working - idles at 800MHz, boosts to max Turbo frequency|
|Laptop Keyboard|Working|
|Laptop Trackpad|Working|
|Laptop Headphones Jack|Working|
|Built-in Speakers|Working|
|Built-in Mic|Working|
|Hotkeys for audio|Working|
|USB 3.x|Working|
|USB 2.0|Working|
|Fingerprint Sensor|Not working|
|SD Card Slot|Working|
|Screen brightness|Working, hotkeys fn+S/fn+B to decrease/increase brightness|
|Built-in Wifi|Working|
|Built-in Bluetooth|Working excepted for Bluetooth 4.0 mice|
|Dell USB3.1 dock|Working|
|RTL8153 USB Ethernet on Dell dock|Working|
|Other peripherals on Dell dock|Working|
|Built-in webcam|Working|
|Sleep|Doesn't works on MacOS, still works on Windows ([see sleep section](https://github.com/BenDevelopment/XPS15-9500-OpenCore#sleep))|
|Multiboot|Working|

---

## Important

This EFI was created from this one https://github.com/zachs78/MacOS-XPS-9500-OpenCore/.

Original nvme SSD Micron was causing MacOS boot crashes. The Micron SSD has been replaced with a Crucial SSD P1 NVMe.

Windows is installed on this Crucial SSD before the OpenCore installation. OpenCore is installed on a second SSD.

Quick Note: My serial number, MLB, and UUID have been removed from the config.plist. Please use CorpNewt's [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) to create your own (search for "GenSMBIOS" on plist to find the values you have to change).

---

## Making the USB installer

To create an EFI bootable USB key with MacOS installer, follow the steps described here:
https://dortania.github.io/OpenCore-Install-Guide/installer-guide/winblows-install.html#downloading-macos-modern

Once the USB key created, replace the EFI folder by the one is this repository. Setup the BIOS as described in the [BIOS Settings section](https://github.com/BenDevelopment/XPS15-9500-OpenCore#bios-settings) and disable CFG Lock as described in the [How to disable CFG Lock section](https://github.com/BenDevelopment/XPS15-9500-OpenCore#how-to-disable-cfg-lock). You can now boot on the USB  key.

---

## BIOS Settings

Disable the following
 - TPM
 - Touchscreen (if enabled, MacOS will consider the touchscreen as trackpad and disable the trackpad)
 - Secure boot
 - Disable CFG Lock (via modGRUBShell)

---

## How to disable CFG Lock

This is specific to XPS 15 9500 only (along with its sibling models and previous gen).

WARNING: tools are disabled on this plist. To activate tools at startup, set `Misc > Boot > ShowPicker=YES` and `Misc > Boot > HideAuxiliary=NO`.

Select the modGRUBShell option at startup (OpenCore boot selection page).
At the grub prompt, enter the following commands (the first line unlocks CFG, the second line unlocks overclocking).

```
setup_var CpuSetup 0x3e 0x0
setup_var CpuSetup 0xda 0x0
exit
```

Restart your laptop and boot into the BIOS. Do a factory reset. Now your CFG lock will be disabled. You can confirm that by running the VerifyMSR2 option.

If you update your BIOS, you may need to do this again but so far Dell has been kind to us.

---

## Sleep

Sleep doesn't works on MacOS. To disable sleep permanently, run this command in MacOS:
```
sudo pmset -a disablesleep 1
```
This way, sleep can be stay enabled on BIOS settings so other OS can still use it. 

---

## Intel® Virtualization Technology for Directed I/O (VT-d) 

This BIOS option allows the virtualized OS to use hardware like if it was not virtualized. This is usefull if you run virtualized OS in Windows or MacOS.
[This is recommended to be disabled by @zachs78](https://github.com/zachs78/MacOS-XPS-9500-OpenCore#bios-settings) but it seems to works well keeping it enabled.
DisableIOMapper must be enabled in plist as said here https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/coffee-lake-plus.html#quirks-3.

---

## Brightness hotkeys

The BRT6 patch used by previous Dell XPS models isn't working on the XPS 9500. However, fn+S and fn+B hotkeys are functioning in place of the original fn+F6 and fn+F7.

---

## Undervolting

This EFI comes preinstalled with VoltageShift kext. To undervolt, visit https://github.com/sicreative/VoltageShift (skip the kext loading part).

---

## rEFInd (Not needed)

__ATTENTION: Bootin Windows 10 works now with OpencCore. rEFInd isn't needed, prefer using OpenCanopy which is already configured on this repository.
You can skip this whole part.__

Windows was not booting via OpenCore picker. The problem was due to OpenCore injecting the dsdt/ssdt for all OS (not only for Darwin). You can read more here: 

- https://dortania.github.io/OpenCore-Install-Guide/why-oc.html#does-opencore-always-inject-smbios-and-acpi-data-into-other-oses
- https://www.insanelymac.com/forum/topic/338516-opencore-discussion/?page=19&tab=comments#comment-2675604.

There are the solutions:
- Previous solution was adding `If (_OSI ("Darwin"))` in all ssdt (according to [my researchs](https://www.reddit.com/r/hackintosh/comments/f9rbcl/need_some_advice_on_opencore_dsdt_edits_for_laptop/fiu1jwl?utm_source=share&utm_medium=web2x&context=3), it can be done but it require to build the ssdt by yourself). 
- Second solution: don't use OpenCore for boot selection.
- __The working solution__ is to use the AML from Dortania: https://github.com/dortania/Getting-Started-With-ACPI/blob/master/extra-files/compiled/SSDT-XOSI.aml (__Already included on this EFI, you have nothing to do)__.

The first one is kind of difficult.
The second one (wich I'm using), is the easier way for me. The goal is to use rEFInd instead of OpenCore for OS picker (OpenCore will still be used only to run MacOS).
Here is the process:

### Install rEFInd

To install rEFInd, follow thoses steps:
- Download rEFInd's files: http://sourceforge.net/projects/refind/files/0.12.0/refind-bin-0.12.0.zip/download
- Mount your system's EFI
- Move OpenCore's `BOOTx64.efi` to `EFI/OC/` (kind of backup)
- Copy rEFInd's `refind_x64.efi` to `EFI/BOOT`
- Rename this `refind_x64.efi` to `BOOTx64.efi`
- Add the rEFInd's folders `drivers_x64`, `tools` and `icons` to `EFI/BOOT`
- Copy `refind.conf-sample` to `EFI/OC`
- Rename `refind.conf-sample` to `refind.conf`

[Source](https://github.com/dortania/Hackintosh-Mini-Guides/blob/master/refind.md#macos-setup)

### Make the computer boot on rEFInd instead of OpenCore

1. Disable OpenCore picker in plist (`Misc > Boot > ShowPicker=NO`). This will automatically run MacOS instead of showing OpenCore picker (OpenCore is still working, this will only disable the picker).
2. Disable `BootProtect` in plist (`Misc > Security > BootProtect=None`). This will prevent OpenCore to automatically set itself as first boot item in your BIOS.
3. Set your macOS drive as first boot device (this is the drive where your EFI partition stands, the one with rEFInd).

Now when you are booting you computer, you should have rEFInd OS picker instead of OpenCore picker. The default rEFIng configuration will show you all the availables EFI partition (displayed with an ugly theme IMO ^^).

This will chain your boot: first rEFInd, then OpenCore (if you boot to MacOS). Booting to Windows will not run through OpenCore, that's why we don't get the `acpi_bios_error` which was causing by OpenCore ACPI DSDT/SSDT injections).

### Theming rEFInd

Using rEFInd allows you to set up aditionnal picker themes easily (there are a lot of themes available for rEFInd in github: https://github.com/topics/refind-theme).

1. Create a `refind/themes` folder on your EFI folder (in your EFI partition) and past the theme folder in this directory.
2. Edit the `BOOT/refind.conf` file like that:
	```
	timeout 20

	menuentry "Windows" {
		icon /EFI/refind/themes/theme-name/icons/os_win.png
		volume ESP
		loader EFI\Microsoft\Boot\bootmgfw.efi
	}

	menuentry "OSX" {
		icon /EFI/refind/themes/theme-name/icons/os_mac.png
		loader EFI/OC/Bootstrap/Bootstrap.efi
	}

	scanfor manual,external

	include /EFI/refind/themes/theme-name/theme.conf
	```
3. In your Windows menuentry, you have to specify the volume of your Windows EFI partition (you can find this name on your MacOS by mounting this partition (you will see the name on your Finder). Mine is `ESP` (for "EFI System Partition").
4. Finally, you have to edit the `theme.conf` file (`/EFI/refind/themes/theme-name/theme.conf`) to update the paths to match your absolute theme folder. Example:
	```
	banner themes/theme-name/background.png
	```
	becomes
	```
	banner /EFI/refind/themes/theme-name/background.png
	```
	Now your rEFInd should be themed. You can create your own theme easily since rEFInd supports common images formats (jpg, png, ...).
	
### Uninstall rEFIind (back to OpenCore)

- Remove refind.conf from `EFI/BOOT`
- Remove the folders `drivers_x64`, `tools` and `icons` from `EFI/BOOT`
- Remove `BOOTx64.efi` from `EFI/BOOT` (this is the rEFInd `efi` file which was `refind_x64.efi` before renamed to `BOOTx64.efi`)
- Move `BOOTx64.efi` from `EFI/OC/` to `EFI/BOOT` (this is the OpenCore original `efi` file)
- Remove the `EFI/refind` folder (it should only contains themes, you can keep it if you plan to reactivate rEFInd later)
