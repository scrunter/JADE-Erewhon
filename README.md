# JADE Erewhon Example Schemas

This fork is the controlled Erewhon application source for the JadeSRE lab. The
native schemas and the .NET Shop remain derived from the upstream JADE sample;
JadeSRE-specific build metadata is in `.jadesre/source-profile.json`, and CI is
owned by Azure DevOps through `pipelines/erewhon-ci.yml`. A deployment must use
an immutable commit and retained artifact hashes, never the mutable `main`
branch as its release identity.
This repository contains **Erewhon**, the example JADE schema. Erewhon is a fictional E-commerce platform where agents sell high-end items and clients can bid on or purchase them.

## Documentation
Documentation for the Erewhon system can be found at: https://secure.jadeworld.com/developer-centre/Jade2022/Erewhon/Erewhon.pdf

## Getting Started
These instructions get a copy of the Erewhon system up and running on your local machine.

### Prerequisites

Before you can load the schemas, you need JADE 2022 installed. 

1. Grab a FREE Developer's license at https://www.jadeplatform.com/developer-centre/licensing/free-development-licence
2. Download the JADE 2022 release at https://www.jadeplatform.com/developer-centre/downloads
3. Open the installer and follow the instructions in the install wizard.
4. JADE is now installed, and a shortcut has been placed in your Start menu. You're good to go!

> For details about installing JADE, see https://secure.jadeworld.com/developer-centre/JADE2022/Docs/InstallConfig.pdf

### Loading the Schemas using JADE Git Integration

**Step 1: Setting your username and email**

1. In the Options menu, select the **Preferences** command.
2. Select the **Source Management** sheet.
3. Enter your name and email address in the **Commit Details** group box inside the **Source Control** group box.
4. Select a valid working directory. (This can be whatever you like, as long as you remember it.)
5. Click the **OK** button.

**Step 2: Cloning the Repository**

1. In the Browse menu, select the **Clone** command from the Git Source Control Client submenu.
(The local path is filled in for you as the path you selected in Step 1.)
2. For the Repository URL, enter https://github.com/jadesoftwarenz/JADE-Erewhon
3. Click the **Clone** button.

**Step 3: Importing the Erewhon Database**
1. In the Schema menu, select the **Load** command.
2. Check the **Load Multiple Schemas** check box.
3. Select the **ErewhonDemoSystem.mul** file in the folder you selected as your working directory.
4. Click the **OK** button, and the Erewhon schemas will be loaded into your Schema Browser ready for use.

**Optional Step: Using the DotNet Shop**
1. Load the Erewhon schemas.
2. Load the initial data using the **initializeData** JadeScript method in ErewhonModelSchema.
3. Navigate to the **ErewhonDotNetShop** folder in your local repository directory.
	
	(You can skip the next two steps if you have installed JADE in **C:\Jade**.)
4. Open **app.config** in your preferred text editor (for example, Notepad++), and change all instances of **C:\Jade** to your JADE install directory
5. If you have renamed your system folder or if your **jade.ini** file is not located in the JADE base directory, modify the file paths, as needed.
6. Open both **.csproj** and files (in their sub-directories) in your preferred text editor (for example, Notepad++), and change all instances of **C:\Jade\bin** to your JADE (binary) install directory.
7. Open both **.config** and files (in their sub-directories) in your preferred text editor (for example, Notepad++), and change all file paths to match the locations of your JADE  INI file, binary and system directory.
8. Make sure you have a JADE database on a server node (that is, jadrap) running for your JADE database, then open **ErewhonDotNetApp.sln** in Microsoft Visual Studio, build, and run it.
   Note.  Both projects in the solution should be built as **x64 Release**, you may need to open the Configuration Manager in Visual Studio and make this change. 
   ErehwonExposures project targets 'net48;net6.0'  and ShopUI project targets 'net6.0-windows'.  The relevant SDK's will need to be installed. 
   The ShopUI Project will be default run as **MultiUser** - so the JADE Database Server must be running.  This can be changed to **SingleUser** in ShopUI\Models\Erewhon.cs

## Frequently Asked Questions
**Q.** Can I contribute to or change these schemas?
> The schemas contained in this repository are for demonstration purposes, and as such, are not open to pull requests. However, you are welcome to create a fork and make changes to your own copy, subject to our license ([LICENSE.txt](LICENSE.txt)).

**Q.** What can I do with this Erewhon system?
> Using the Administration application, you can take the role of a sales agent and post items for your (fictional) clients to buy. Using the **ErewhonShop** application, you can take the role of a client and bid for or buy (fictional) items. For more details, see https://secure.jadeworld.com/developer-centre/Jade2022/Erewhon/Erewhon.pdf.

## License

This project is licensed under the MIT License. See the [LICENSE.txt](LICENSE.txt) file for details.
