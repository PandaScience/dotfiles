# Nuphy Air60 V2

## How to modify keymaps

- Open https://usevia.app/ in chrome-based browser
- Settings -> Show Design Tab
- Make sure to disable -> Use V2 definitions (deprecated)
- In configure tab -> authorize device -> select Air60 V2
- On Error:

  ```
  Failed to open '/dev/hidraw4': FILE_ERROR_ACCESS_DENIED
  Access denied opening device read-write, trying read-only.
  ```

  - check in chrome://device-log/ check which device is not allowed
  - run `sudo chmod a+rw /dev/hidraw${N}` to allow access to the device
  - cf. https://github.com/the-via/releases/issues/257
