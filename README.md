# Interactive CSR Generator
```
 _______  _______  ______        _______  _______  __    _ 
|       ||       ||    _ |      |       ||       ||  |  | |
|       ||  _____||   | ||      |    ___||    ___||   |_| |
|       || |_____ |   |_||_     |   | __ |   |___ |       |
|      _||_____  ||    __  |    |   ||  ||    ___||  _    |
|     |_  _____| ||   |  | |    |   |_| ||   |___ | | |   |
|_______||_______||___|  |_|    |_______||_______||_|  |__|
```

A Bash script to interactively generate a Certificate Signing Request (CSR) and private key.  
Supports both wildcard (`*.example.com`) and standard (`example.com`) CSRs, builds a minimal OpenSSL config, and displays the generated CSR.

---

## Table of Contents

- [Features](#features)  
- [Prerequisites](#prerequisites)  
- [Installation](#installation)  
- [Usage](#usage)  
- [Script Flow](#script-flow)  
- [Options & Prompts](#options--prompts)  
- [Example Run](#example-run)  
- [Directory Layout](#directory-layout)  
- [acknowledgment](#acknowledgment)
---

## Features

- Interactive prompts for:
  - Output directory (default: `~/user/CSR`)
  - CSR type: wildcard or standard
  - Domain name
  - Final confirmation before proceeding
- Automatic creation of `.key`, `.csr.cnf` (OpenSSL config), and `.csr` files
- Per-domain subdirectory to avoid collisions
- Built-in validation of user inputs
- Clean, reusable script with clear progress messages

---

## Prerequisites

- **bash** (tested on GNU Bash 4+)
- **OpenSSL** CLI (`openssl`)
- Write permissions to your chosen output directory

---

## Installation

1. Copy the script to your local machine:
```bash
   curl -O https://example.com/Interactive-CSR-generator.sh
   chmod +x Interactive-CSR-generator.sh
````

2. (Optional) Move it into your PATH:

```bash
   mv Interactive-CSR-generator.sh /usr/local/bin/interactive-csr
```

---

## Usage

```bash
./Interactive-CSR-generator.sh
```

The script will walk you through:

1. Choosing (or accepting) a default output directory.
2. Selecting CSR type (wildcard vs. standard).
3. Entering the domain name (with validation).
4. Confirming your choices.
5. Generating:

   * A 2048-bit RSA private key (`<domain>.key`)
   * An OpenSSL config file (`<domain>.csr.cnf`)
   * The CSR file (`<domain>.csr`)
6. Displaying the CSR content for easy copy/paste.

All artifacts are placed in:

```
<CSR_DIR>/<effective-domain>/
```

---

## Script Flow

1. **Banner & Divider**
2. **Prompt for CSR directory** (`~/user/CSR` default)
3. **Prompt for CSR type**

   * `1` → wildcard (`*.example.com`)
   * `2` → standard (`example.com`)
4. **Domain name input & validation**
5. **Confirmation prompt**
6. **Create per-domain subdirectory**
7. **Generate RSA 2048 private key**
8. **Generate OpenSSL config**

   * Wildcard: includes both `DNS.1 = example.com` and `DNS.2 = *.example.com`
   * Standard: includes `DNS.1 = example.com` and `DNS.2 = www.example.com` plus key usage extensions
9. **Generate CSR**
10. **Display CSR details**

---

## Options & Prompts

| Prompt                     | Default / Values                         |
| -------------------------- | ---------------------------------------- |
| **CSR directory**          | `~/user/CSR`                              |
| **CSR type**               | `1` (wildcard) or `2` (standard)         |
| **Domain name**            | User-entered; must match chosen CSR type |
| **Confirm domain** (`Y/N`) | `Y`                                      |

---

## Example Run

```console
$ ./Interactive-CSR-generator.sh

=================================================================================
 _______  _______  ______        _______  _______  __    _ 
|       ||       ||    _ |      |       ||       ||  |  | |
|       ||  _____||   | ||      |    ___||    ___||   |_| |
|       || |_____ |   |_||_     |   | __ |   |___ |       |
|      _||_____  ||    __  |    |   ||  ||    ___||  _    |
|     |_  _____| ||   |  | |    |   |_| ||   |___ | | |   |
|_______||_______||___|  |_|    |_______||_______||_|  |__|

=================================================================================

Enter CSR directory [Default: /home/alice/user/CSR]:
Directory /home/alice/user/CSR already exists.

Enter 1 for wildcard (*.example.com)
Enter 2 for standard (example.com)

1 OR 2? [Default is 1] : 
You have chosen a wildcard CSR. The domain must start with '*.' 
Enter the domain name: *.example.com

=================================================================================
CSR is being created in /home/alice/user/CSR/star.example.com 
=================================================================================

Is the entered domain '*.example.com' correct? (Y/N) [Default Y]: 

=================================================================================
Directory /home/alice/user/CSR/star.example.com created.
=================================================================================

=================================================================================
Creating RSA 2048 Key for *.example.com ...
=================================================================================
Creation of RSA 2048 Key for *.example.com was successful.
=================================================================================

=================================================================================
Configuration file *.example.com.csr.cnf created.
=================================================================================

=================================================================================
Creating CSR for *.example.com ...
=================================================================================
CSR for *.example.com created successfully as star.example.com.csr.
=================================================================================

=================================================================================
Operation completed. Outputting your /home/alice/user/CSR/star.example.com.csr :

-----BEGIN CERTIFICATE REQUEST-----
...
-----END CERTIFICATE REQUEST-----

=================================================================================
```

---

## Directory Layout

```
~/user/CSR/
└── star.example.com/
    ├── star.example.com.key
    ├── *.example.com.csr.cnf
    └── star.example.com.csr
```

---
## acknowledgment
### Contributors

APA 🖖🏻

```
  aaaaaaaaaaaaa  ppppp   ppppppppp     aaaaaaaaaaaaa   
  a::::::::::::a p::::ppp:::::::::p    a::::::::::::a  
  aaaaaaaaa:::::ap:::::::::::::::::p   aaaaaaaaa:::::a 
           a::::app::::::ppppp::::::p           a::::a 
    aaaaaaa:::::a p:::::p     p:::::p    aaaaaaa:::::a 
  aa::::::::::::a p:::::p     p:::::p  aa::::::::::::a 
 a::::aaaa::::::a p:::::p     p:::::p a::::aaaa::::::a 
a::::a    a:::::a p:::::p    p::::::pa::::a    a:::::a 
a::::a    a:::::a p:::::ppppp:::::::pa::::a    a:::::a 
a:::::aaaa::::::a p::::::::::::::::p a:::::aaaa::::::a 
 a::::::::::aa:::ap::::::::::::::pp   a::::::::::aa:::a
  aaaaaaaaaa  aaaap::::::pppppppp      aaaaaaaaaa  aaaa
                  p:::::p                              
                  p:::::p                              
                 p:::::::p                             
                 p:::::::p                             
                 p:::::::p                             
                 ppppppppp                             
```