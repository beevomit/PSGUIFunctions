#Requires -Version 5

# Collection of cobbled together Powershell functions for GUI based message and user input prompts.

function Select-Folder {
    <#
    .SYNOPSIS
     Opens a folder selection dialog and returns full path to the folder.

    .EXAMPLE
     $selectedFolder = Select-Folder
    #>
    Add-Type -AssemblyName System.Windows.Forms
    $FolderSelect = New-Object System.Windows.Forms.FolderBrowserDialog
    $null = $FolderSelect.ShowDialog()
    $SelectedFolder = $FolderSelect.SelectedPath
    return $SelectedFolder
}


function Select-File {
    <#
    .SYNOPSIS
     Opens a file selection dialog and returns full path to the file.

    .PARAMETER InitialDialogDir
    Specifies the inital directory to start in the dialog. If unspecified it defaults to the root of the home drive.

    .EXAMPLE
    $selectedFile = Select-File -InitialDialogDir "C:\Users\Public\Documents"
    #>
    param (
        [Parameter(Mandatory=$false)]
        [String] $InitialDialogDir = "$env:HOMEDRIVE"
    )
    Add-Type -AssemblyName System.Windows.Forms
    $FileSelect = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = $InitialDialogDir
        filter = "All files (*.*)| *.*"
    }
    $null = $FileSelect.ShowDialog()
    $SelectedFile = $FileSelect.FileName
    return $SelectedFile
}


function Save-File {
    <#
    .SYNOPSIS
    Creates a save file dialog and returns the path and name of the file to save.

    .PARAMETER InitialDialogDir
    Specifies the initial directory to start in the dialog. If unspecified it defaults to the root of the home drive.

    .EXAMPLE
    $saveFile = Save-File -InitialDialogDir "C:\Users\Public\Documents"
    #>
    param (
        [Parameter(Mandatory=$false)]
        [String]
        $InitialDialogDir = "$env:HOMEDRIVE"
    )
    Add-Type -AssemblyName System.Windows.Forms
    $FileSelect = New-Object System.Windows.Forms.SaveFileDialog -Property @{
        InitialDirectory = $InitialDialogDir
        filter = "All files (*.*)| *.*"
    }
    $null = $FileSelect.ShowDialog()
    $SelectedFile = $FileSelect.FileName
    return $SelectedFile
}


function Show-MessageBox {
    <#
    .SYNOPSIS
    Displays a message box and returns the button pressed in response.

    .PARAMETER MessageText
    Specifies the main text of the message to display.

    .PARAMETER MessageTitle
    Specifies the title of the message box.

    .PARAMETER ButtonOptions
    Specifies the button types shown for response to the message box. Default is 'OKCancel'.

    .PARAMETER MessageBoxIcon
    Specifies the icon displayed on the message box to indicate it's type. Default is 'Information'.

    .PARAMETER MessageBoxDefaultButton
    Specifies the default button to be activated on the message box. Default is 'Button1'.

    .EXAMPLE
    $returnedMessageBoxButton = Show-MessageBox -MessageText "Hello, World" -MessageTitle "Hello World"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $MessageText,
        [Parameter(Mandatory=$false)]
        [String]
        $MessageTitle = "Message",
        [Parameter(Mandatory=$false)]
        [String]
        $ButtonOptions = "OKCancel",  # YesNoCancel, AbortRetryIgnore, YesNo, RetryCancel
        [Parameter(Mandatory=$false)]
        [String]
        $MessageBoxIcon = "Information",  # Error, Question, Warning, Stop, Hand
        [Parameter(Mandatory=$false)]
        [String]
        $MessageBoxDefaultButton = "Button1"  # Button2, Button3
    )
    Add-Type -AssemblyName System.Windows.Forms
    $ButtonReturn=[System.Windows.Forms.MessageBox]::Show("$MessageText","$MessageTitle", +
    [System.Windows.Forms.MessageBoxButtons]::$ButtonOptions,[System.Windows.Forms.MessageBoxIcon]::$MessageBoxIcon, +
    [System.Windows.Forms.MessageBoxDefaultButton]::$MessageBoxDefaultButton)
    return $ButtonReturn
}


function Get-UserInput {
    <#
    .SYNOPSIS
    Displays a user input box and returns the user's input as a string (default) or integer (see parameter).

    .PARAMETER InputMessage
    Specifies the main text of the input box message to display.

    .PARAMETER InputTitle
    Specifies the title of the input box.

    .PARAMETER DefaultInput
    Allows you to set an initial default input value for the user.

    .PARAMETER ReturnAsInteger
    Default is set to '$false'. Set to '$true' to convert input from string to integer (if conversion is possible).

    .EXAMPLE
    $userInput = Get-UserInput -InputMessage "What is your name?" -InputTitle "Your Information"
    $userInput = Get-UserInput -InputMessage "How old are you?" -ReturnAsInteger $true
    #>
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $InputMessage,
        [Parameter(Mandatory=$false)]
        [String]
        $InputTitle = "Input Request",
        [Parameter(Mandatory=$false)]
        [String]
        $DefaultInput,
        [Parameter(Mandatory=$false)]
        [bool]
        $ReturnAsInteger = $false  # Set to "$true" if you want a numeric string converted to an integer
    )
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $UsersInput = [Microsoft.VisualBasic.Interaction]::InputBox($InputMessage, $InputTitle, $DefaultInput)
    if ($ReturnAsInteger -eq $true -and $UsersInput -match "^\d+$") {
        return [int]$UsersInput
    } else {
        return $UsersInput
    }
}


# Display Listbox Input Selection
function Show-ListBox {
    <#
    .SYNOPSIS
    Displays a listbox and returns single or multiple choices from the list of items. (Uses Powershell's Out-GridView.)

    .PARAMETER ItemsForList
    List items must be passed in from a Powershell array. 

    .PARAMETER ChoiceMode
    Allows you to set for 'Single' item only or 'Multiple' item selections by user. Default is 'Single'.
    Single items are returned as System.String type, multiple items are returned as a System.Object[] type.

    .PARAMETER BoxTitle
    Specifies the title of the list box and can be used to ask for selection.

    .PARAMETER SortListItems
    Allows you to specify if list item are sorted (e.g. alphabetically). Default is '$false'.

    .EXAMPLE
    $listItems = @('Jack','John','Jill','Jane')
    $userInput = Show-ListBox -ItemsForList $listItems -BoxTitle "Please choose a name:" -ChoiceMode "Single" -SortListItems $true
    #>
    param (
        [Parameter(Mandatory=$true)]
        [array]
        $ItemsForList,  # List items passed in as an array
        [Parameter(Mandatory=$false)]
        [String]
        $ChoiceMode = "Single",  # "Single" (default) or "Multiple" item selection
        [Parameter(Mandatory=$false)]
        [String]
        $BoxTitle = "Choose item below and press OK:",
        [Parameter(Mandatory=$false)]
        [bool]
        $SortListItems = $false  # Set to "$true" if you want to sort the list items alphanumerically
    )
    if ($SortListItems) {
        $SelectedBoxItems = $ItemsForList | Sort-Object | Out-GridView -OutputMode $ChoiceMode -Title $BoxTitle
    } else {
        $SelectedBoxItems = $ItemsForList | Out-GridView -OutputMode $ChoiceMode -Title $BoxTitle
    }
    return $SelectedBoxItems
}
