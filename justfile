default: build run

[private]
incrementBuildNumber:
    #! /bin/python3
    from sys import argv

    f = open("src/pdxinfo","r")
    content = f.read()
    f.close()

    contentLines = content.split("\n")

    for i, line in enumerate(contentLines):
        if line.startswith("buildNumber="):
            buildnum = int(line.split("=")[1])
            buildnum += 1
            contentLines[i] = "buildNumber=" + str(buildnum)
            break

    f = open("src/pdxinfo","w")

    f.write("\n".join(contentLines))

    print(contentLines)


build:
    @just incrementBuildNumber

    pdc -q src musik

run:
    PlaydateSimulator musik.pdx

release:
    just build
    -rm musik.pdx.zip
    zip -rq musik.pdx.zip musik.pdx
