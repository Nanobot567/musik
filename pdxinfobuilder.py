# build pdxinfo from already existing one
from sys import argv

f = open("src/pdxinfo","r")
content = f.read()
f.close()

splitnl = content.split("\n")
sc = splitnl[5].split("=")
buildnum = sc[1]

splitnl[5] = f"buildNumber={str(int(buildnum)+1)}"

f = open("src/pdxinfo","w")

for i in splitnl:
    if splitnl[len(splitnl)-1] == i:
        f.write(f"{i}")
    else:
        f.write(f"{i}\n")

print(splitnl)