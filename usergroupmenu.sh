#!/bin/bash

# Main menu
while true; do
    CHOICE=$(whiptail --title "User and Group Management" --menu "Choose an option" 15 60 4 \
        "1" "User options" \
        "2" "Group options" \
        "3" "Exit" 3>&1 1>&2 2>&3)

    # User menu
    if [ $CHOICE = "1" ]; then
        while true; do
            USER_CHOICE=$(whiptail --title "User Options" --menu "Choose an option" 15 60 6 \
                "1" "Add user" \
                "2" "Modify user" \
                "3" "List users" \
                "4" "Enable user" \
                "5" "Disable user" \
                "6" "Change user password" \
                "7" "Back" 3>&1 1>&2 2>&3)

			case $USER_CHOICE in


				1)
					USERNAME=$(whiptail --title "Add User" --inputbox "Enter username" 10 60 3>&1 1>&2 2>&3)
					if [ -z "$USERNAME" ]; then
						whiptail --title "Add User" --msgbox "Username cannot be empty" 10 60
					elif id -u "$USERNAME" >/dev/null 2>&1; then
						whiptail --title "Add User" --msgbox "User $USERNAME already exists" 10 60
					else
						sudo useradd "$USERNAME"
						whiptail --title "Add User" --msgbox "User $USERNAME created successfully" 10 60
					fi
					;;

				2)
					while true; do
						MODIFY_USER_CHOICE=$(whiptail --title "Modify User" --menu "Choose an option" 15 60 3 \
							"1" "Add user to group" \
							"2" "Remove user from group" \
							"3" "Back" 3>&1 1>&2 2>&3)

						case $MODIFY_USER_CHOICE in
							1)
								USERNAME=$(whiptail --title "Add User to Group" --inputbox "Enter username" 10 60 3>&1 1>&2 2>&3)
								if [ -z "$USERNAME" 	]; then
									whiptail --title "Add User to Group" --msgbox "Username cannot be empty" 10 60
								elif ! id "$USERNAME" >/dev/null 2>&1; then
									whiptail --title "Add User to Group" --msgbox "User $USERNAME does not exist" 10 60
								else
									GROUPNAME=$(whiptail --title "Add User to Group" --inputbox "Enter group name" 10 60 3>&1 1>&2 2>&3)
									if [ -z "$GROUPNAME" ]; then
										whiptail --title "Add User to Group" --msgbox "Group name cannot be empty" 10 60
									elif ! grep -q "^$GROUPNAME:" /etc/group; then
										whiptail --title "Add User to Group" --msgbox "Group $GROUPNAME does not exist" 10 60
									else
										sudo usermod  -a -G $GROUPNAME $USERNAME
											whiptail --title "Add User to Group" --msgbox "User $USERNAME added to group $GROUPNAME successfully" 10 60
										fi
									fi
									;;
							2)
								USERNAME=$(whiptail --title "Remove User from Group" --inputbox "Enter username" 10 60 3>&1 1>&2 2>&3)
								if [ -z "$USERNAME" ]; then
									whiptail --title "Remove User from Group" --msgbox "Username cannot be empty" 10 60
								elif ! id "$USERNAME" >/dev/null 2>&1; then
									whiptail --title "Remove User from Group" --msgbox "User $USERNAME does not exist" 10 60
								else
									GROUPNAME=$(whiptail --title "Remove User from Group" --inputbox "Enter group name" 10 60 3>&1 1>&2 2>&3)
									if [ -z "$GROUPNAME" ]; then
										whiptail --title "Remove User from Group" --msgbox "Group name cannot be empty" 10 60
									elif ! grep -q "^$GROUPNAME:" /etc/group; then
										whiptail --title "Remove User from Group" --msgbox "Group $GROUPNAME does not exist" 10 60
									elif ! id -nG "$USERNAME" | grep -qw "$GROUPNAME"; then
										whiptail --title "Remove User from Group" --msgbox "User $USERNAME is not a member of group $GROUPNAME" 10 60
									else
										sudo deluser $USERNAME $GROUPNAME
										whiptail --title "Remove User from Group" --msgbox "User $USERNAME removed from group $GROUPNAME successfully" 10 60
									fi
								fi
								;;
							3)
								break
									;;
							*)
								whiptail --title "Error" --msgbox "Invalid option" 10 60
									;;
							esac
					done
						;;
			3)
				USERS=$(sudo awk -F':' '$3 >= 1000 { print $1 }' /etc/passwd | tr '\n' '  ')
				whiptail --title "List Users" --msgbox "Users: $USERS" 10 60
				;;

			4)
				USERNAME=$(whiptail --title "Enable User" --inputbox "Enter username" 10 60 3>&1 1>&2 2>&3)
				if [ -z "$USERNAME" ]; then
					whiptail --title "Enable User" --msgbox "Username cannot be empty" 10 60
				elif ! id -u "$USERNAME" >/dev/null 2>&1; then
					whiptail --title "Enable User" --msgbox "User $USERNAME does not exist" 10 60
				else
					sudo usermod -U "$USERNAME"
					whiptail --title "Enable User" --msgbox "User $USERNAME enabled successfully" 10 60
				fi
				;;

			5)
			 USERNAME=$(whiptail --title "Disable User" --inputbox "Enter username" 10 60 3>&1 1>&2 2>&3)
				if [ -z "$USERNAME" ]; then
					whiptail --title "Error" --msgbox "Username cannot be empty. Please try again." 10 60
			 elif ! id "$USERNAME" &>/dev/null; then
					whiptail --title "Error" --msgbox "User '$USERNAME' does not exist. Please try again." 10 60
				else
					sudo usermod -e "" "$USERNAME"
					 whiptail --title "Disable User" --msgbox "User $USERNAME disabled successfully" 10 60
				fi
			 ;;

			6)
			 USERNAME=$(whiptail --title "Change User Password" --inputbox "Enter username" 10 60 3>&1 1>&2 2>&3)
			 if [ -z "$USERNAME" ]; then
					whiptail --title "Error" --msgbox "Username cannot be empty. Please try again." 10 60
			 elif ! id "$USERNAME" &>/dev/null; then
					 whiptail --title "Error" --msgbox "User '$USERNAME' does not exist. Please try again." 10 60
			 else
					PASSWORD=$(whiptail --title "Change User Password" --passwordbox "Enter new password" 10 60 3>&1 1>&2 2>&3)
					 if [ -z "$PASSWORD" ]; then
							whiptail --title "Error" --msgbox "Password cannot be empty. Please try again." 10 60
					 else
						echo "$PASSWORD" | sudo passwd --stdin "$USERNAME"
						whiptail --title "Change User Password" --msgbox "Password for user $USERNAME changed successfully" 10 60
					fi
				 fi
			 ;;

				 7)
				 break
				  ;;
				 
			*)
				whiptail --title "Invalid choice" --msgbox "Please select a valid option" 10 60
				;;
				esac
				done

    # Group menu
    elif [ $CHOICE = "2" ]; then
        while true; do
            GROUP_CHOICE=$(whiptail --title "Group Options" --menu "Choose an option" 15 60 4 \
                "1" "Add group" \
                "2" "Modify group" \
                "3" "List groups" \
                "4" "Back" 3>&1 1>&2 2>&3)

  case $GROUP_CHOICE in
                1)
                    GROUPNAME=$(whiptail --title "Add Group" --inputbox "Enter group name" 10 60 3>&1 1>&2 2>&3)
                    if [ -z "$GROUPNAME" ]; then
                        whiptail --title "Add Group" --msgbox "Group name cannot be empty" 10 60
                    elif grep -q "^$GROUPNAME:" /etc/group; then
                        whiptail --title "Add Group" --msgbox "Group $GROUPNAME already exists" 10 60
                    else
                        sudo groupadd $GROUPNAME
                        whiptail --title "Add Group" --msgbox "Group $GROUPNAME added successfully" 10 60
                    fi
                    ;;
                2)
                    while true; do
					GROUP_NAME=$(whiptail --title "Modify Group" --inputbox "Enter group name" 10 60 3>&1 1>&2 2>&3)
                        if [ -z "$GROUP_NAME" ]; then
                            whiptail --title "Modify Group" --msgbox "Group name cannot be empty" 10 60
                        elif ! grep -q "^$GROUP_NAME:" /etc/group; then
                            whiptail --title "Modify Group" --msgbox "Group $GROUP_NAME does not exist" 10 60
                        else
                            while true; do
                                MODIFY_GROUP_CHOICE=$(whiptail --title "Modify Group: $GROUP_NAME" --menu "Choose an option" 15 60 4 \
                                    "1" "Add user to group" \
                                    "2" "Remove user from group" \
                                    "4" "Back" 3>&1 1>&2 2>&3)

                                case $MODIFY_GROUP_CHOICE in
                                    1)
                                        USERNAME=$(whiptail --title "Add User to Group" --inputbox "Enter username" 10 60 3>&1 1>&2 2>&3)
                                        if [ -z "$USERNAME" ]; then
                                            whiptail --title "Add User to Group" --msgbox "Username cannot be empty" 10 60
                                        elif ! id "$USERNAME" >/dev/null 2>&1; then
                                            whiptail --title "Add User to Group" --msgbox "User $USERNAME does not exist"
											elif groups "$USERNAME" | grep -q "\b$GROUP_NAME\b"; then
                                        whiptail --title "Add User to Group" --msgbox "User $USERNAME is already in group $GROUP_NAME" 10 60
                                    else
                                        sudo usermod -aG "$GROUP_NAME" "$USERNAME"
                                        whiptail --title "Add User to Group" --msgbox "User $USERNAME added to group $GROUP_NAME" 10 60
                                    fi
                                    ;;
                                2)
                                    USERNAME=$(whiptail --title "Remove User from Group" --inputbox "Enter username" 10 60 3>&1 1>&2 2>&3)
                                    if [ -z "$USERNAME" ]; then
                                        whiptail --title "Remove User from Group" --msgbox "Username cannot be empty" 10 60
                                    elif ! id "$USERNAME" >/dev/null 2>&1; then
                                        whiptail --title "Remove User from Group" --msgbox "User $USERNAME does not exist" 10 60
                                    elif ! groups "$USERNAME" | grep -q "\b$GROUP_NAME\b"; then
                                        whiptail --title "Remove User from Group" --msgbox "User $USERNAME is not in group $GROUP_NAME" 10 60
                                    else
                                        sudo gpasswd -d "$USERNAME" "$GROUP_NAME"
                                        whiptail --title "Remove User from Group" --msgbox "User $USERNAME removed from group $GROUP_NAME" 10 60
                                    fi
                                    ;;
                                3)
                                    break 2
                                    ;;
                            esac
                        done
                    fi
                done
                ;;
                3)
		   GROUPSLIST=$(awk -F: '{print $1}' /etc/group|tr '\n' '  ')
                    whiptail --title "List Groups" --msgbox "List of groups:\n$GROUPSLIST" 20 60
                    ;;
                4)
                    break
                    ;;
                *)
                    whiptail --title "Invalid choice" --msgbox "Please select a valid option" 10 60
                    ;;
            esac
        done
 # Exit
 		elif [ $CHOICE = "3" ]; then
        		exit
fi
done
