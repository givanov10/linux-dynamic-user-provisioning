# Linux Dynamic User & Group Provisioning Script (With Validation Loops)

An advanced, interactive Bash script that automates enterprise-level account provisioning, directory isolation, and security compliance using dynamic user inputs and real-time system duplicate checks.

## 📋 Scenario Requirements
Unlike static deployment scripts, this solution is fully interactive. It accepts **any** runtime username and group name dynamically (no hardcoding). It strictly verifies system uniqueness against existing assets and implements ironclad group-level security formatting.

## ⚡ Technical Highlights & Logic Flow
* **Interactive Variable Handling:** Utilizes `read` to capture runtime arguments directly into memory buffers (`$GROUP_NAME`, `$USER_NAME`).
* **Active Duplicate Verification Loops:** Engineered with advanced `while` cycles paired with silent `grep -wq` queries to scan `/etc/group` and `/etc/passwd` instantly [NDG Linux Essentials Challenge Lab A]. If a collision is detected, it flags an error and traps the operator in a loop until a unique string is supplied [NDG Linux Essentials Challenge Lab A].
* **Regex Baseline Parsing:** Employs precise boundary patterns (`^$USER_NAME:`) to secure target string matching against system user maps, preventing partial substring collisions [NDG Linux Essentials Challenge Lab A].
* **Hardened Directory Isolation:** Auto-deploys a target root branch (`/$USER_NAME`), transfers strict dynamic ownership (`chown`), applies an isolated `770` permission block, and layers the system **Sticky Bit (+t)** to block unauthorized cross-user modifications [NDG Linux Essentials Challenge Lab A].

## 🛠️ The Script (`user_manager.sh`)
```bash
#!/bin/bash

# 1. REQUEST AND VERIFY SYSTEM GROUP
echo "Please enter the group name:"
read GROUP_NAME

while grep -wq "$GROUP_NAME" /etc/group; do
    echo "Error: Group already exists!"
    echo "Please try another group name:"
    read GROUP_NAME
done

groupadd "$GROUP_NAME"

# 2. REQUEST AND VERIFY SYSTEM USER
echo "Please enter your username:"
read USER_NAME

while grep -q "^$USER_NAME:" /etc/passwd; do
     echo "Error: User already exists!"
     echo "Please try another user name:"
     read USER_NAME
done 

# 3. PROVISION USER AND GENERATE CREDENTIALS
useradd -g "$GROUP_NAME" -s /bin/bash "$USER_NAME"
echo "$USER_NAME:password123" | chpasswd

# 4. DEPLOY AND SECURE DIRECTORY LAYOUT
mkdir -p /$USER_NAME
chown $USER_NAME:$GROUP_NAME /$USER_NAME
chmod 770 /$USER_NAME
chmod +t /$USER_NAME

echo "Setup completed successfully for $USER_NAME!"
```

## 🔍 Execution Verification
A test deploy using `Wolf` as the group and `Witcher` as the user passed compliance verification:
```bash
\$ sudo ./user_manager.sh
Please enter the group name: Wolf
Please enter your username: Witcher
Setup completed successfully for Witcher!
