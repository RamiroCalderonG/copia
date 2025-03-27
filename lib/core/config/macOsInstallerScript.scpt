-- Prompt user to select files
set appPath to POSIX path of (choose file with prompt "Select the oxschool Application file to copy to ~/Applications")
set scpPath to POSIX path of (choose file with prompt "Select the update.scpt file to copy to ~/Home")
set updateHelperPath to POSIX path of (choose file with prompt "Select oxsUpdaterHelper file to copy to ~/Home")

-- Remove trailing slash from appPath if it exists
set appPath to do shell script "echo " & quoted form of appPath & " | sed 's:/*$::'"

-- Define destination paths
set appDest to POSIX path of (do shell script "echo ~/Applications/") & (do shell script "basename " & quoted form of appPath)
set scpDest to POSIX path of (do shell script "echo ~/update.scpt")
set oxsUpdaterHelperDest to POSIX path of (do shell script "echo ~/oxsUpdaterHelper")
log "Destination paths defined:::::" & appDest & scpDest & oxsUpdaterHelperDest

-- Validate and delete existing files in the destination
log "Checking if files already exist in the destination"
try
	-- Check and delete the .app file if it exists
	if (do shell script "test -e " & quoted form of appDest & " && echo true || echo false") is "true" then
		log "Deleting existing .app file at destination: " & appDest
		do shell script "rm -rf " & quoted form of appDest
	end if
	
	-- Check and delete the update.scpt file if it exists
	if (do shell script "test -e " & quoted form of scpDest & " && echo true || echo false") is "true" then
		log "Deleting existing update.scpt file at destination: " & scpDest
		do shell script "rm -f " & quoted form of scpDest
	end if
	
	-- Check and delete the oxsUpdaterHelper file if it exists
	if (do shell script "test -e " & quoted form of oxsUpdaterHelperDest & " && echo true || echo false") is "true" then
		log "Deleting existing oxsUpdaterHelper file at destination: " & oxsUpdaterHelperDest
		do shell script "rm -f " & quoted form of oxsUpdaterHelperDest
	end if
on error errMsg
	log "Error while deleting existing files: " & errMsg
end try

-- Copy files
log "Start to copy files"
do shell script "cp -R " & quoted form of appPath & " ~/Applications/"
do shell script "cp -f " & quoted form of scpPath & " ~/"
do shell script "cp -f " & quoted form of updateHelperPath & " ~/"

-- Change permissions for updateHelper
log "Change permissions for updateHelper"
do shell script "sudo chmod +x ~/oxsUpdaterHelper" with administrator privileges

-- Modify sudoers file safely
log "Modify sudoers file safely"
try
	-- Check if the line already exists in the sudoers file
	set sudoersLine to "ALL ALL=(ALL) NOPASSWD: /usr/bin/xattr -dr com.apple.quarantine"
	set checkCommand to "grep -q " & quoted form of sudoersLine & " /etc/sudoers"
	set appendCommand to "echo " & quoted form of sudoersLine & " | sudo tee -a /etc/sudoers"
	
	-- Run the check command
	try
		do shell script checkCommand with administrator privileges
		log "The sudoers line already exists. Skipping addition."
	on error
		-- If the line does not exist, append it
		do shell script appendCommand with administrator privileges
		log "The sudoers line was added successfully."
	end try
on error errMsg
	log "Error while modifying sudoers file: " & errMsg
end try