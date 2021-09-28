


# Genarate data with [Faker](https://faker.readthedocs.io/en/master/)

You need to install the [faker module](https://pypi.org/project/Faker/) in order to use the script.

```bash
pip install faker
```

---

# CSV Format

The python script will only generate the **id**, **surname** and **givenname**. \
You need to manually add the **OU** for each users.

easy to do with notepad++:

ctrl+H

search mode : **regex**

search : `$` \
replace with: `;OU_NAME`


| ID  | Surname | GivenName | OU |
|:---:|:---:|:---:|:---:|
| 1 | John | Doe | Support |
| 2 | Jane | Doe | Tech | 

Exemple:
```csv
ID;Surname;GivenName;OU
1;Jonh;Doe;Support
2;Jane;Doe;Tech
[...]
```

---
