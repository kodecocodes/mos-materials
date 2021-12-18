# Image Sipper

Just a few notes here in case anyone wants to play with the app before the chapters appear.

You can select an image file or drag one into the Edit Image tab.
You can select a folder of images or drag one in to the Make Thumbnails tab.

CommandRunner.swift contains the basic structure to call any Terminal command.
SipsRunner.swift has specific methods that call CommandRunner to perform the actions.

The app publishes a service that allows you to choose Open in ImageSipper from
the Services menu when either an image file or a folder is selected.
If this is not showing up, use these two Terminal commands to update:

```
/System/Library/CoreServices/pbs -flush
/System/Library/CoreServices/pbs -update
```

The app also publishes an Intent for use in the Shortcuts app.
Check out the Shortcut.png screen shot in the project for an example of how
you can set up a shortcut action.
