# fifo_comparer
A tool to compare two dolphin processes with a set of fifologs to look for differences

Inputs:
  - A directory where the first Dolphin exe exists
  - A directory where the second Dolphin exe exists
  - A directory with one or more fifo logs
  - The directory that the imagemagick program 'magick' exists
  
Ex:  **ruby fifocomparer.rb pr-5337-dolphin-latest-x64 dolphin-master-5.0-4373-x64 tests /path/to/imagemagick/**

After running, you will see Dolphin pop up multiple times as it runs through your tests.  After the tests finish you will have two directories in the same location as the script: "Results" and "Comparisons".

Here's an example of what it might look like:

Results /
  <game-name>.dff /
    D3D /
      pr-5337-dolphin-latest-x64 /
        framedump_1.png
        framedump_2.png
      dolphin-master-5.0-4373-x64 /
        framedump_1.png
        framedump_2.png
    OGL /
      pr-5337-dolphin-latest-x64 /
        framedump_1.png
        framedump_2.png
      dolphin-master-5.0-4373-x64 /
        framedump_1.png
        framedump_2.png
    Vulkan /
      pr-5337-dolphin-latest-x64 /
        framedump_1.png
        framedump_2.png
      dolphin-master-5.0-4373-x64 /
        framedump_1.png
        framedump_2.png

Comparisons /
  <game-name>.dff /
    D3D /
      framedump_1.png
      framedump_2.png
    OGL /
      framedump_1.png
      framedump_2.png
    Vulkan /
      framedump_1.png
      framedump_2.png
