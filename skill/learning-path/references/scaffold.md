# Topic folder scaffold

Build setup only. The skill creates the topic folder `learning/<slug>/code/NN-<topic-slug>/` with the files below and nothing else. It never writes source classes or test files: the learner writes all of them.

## Never overwrite

Check first. If the folder already exists, reuse it exactly as it is: create nothing in it, change nothing in it, not even a missing `pom.xml`. Tell the learner in one line that the folder exists and was reused. Only create a folder, and only create the files below, when the folder does not exist.

## Java

Create:
- `pom.xml`
- `src/main/java/.gitkeep`
- `src/test/java/.gitkeep`

Look up versions at creation time with WebSearch: the latest stable `org.junit.jupiter:junit-jupiter` (the current major line, use the exact latest release) and the latest stable `maven-surefire-plugin`. Do not use versions from memory; if the versions cannot be confirmed with WebSearch/WebFetch (for example offline), still write the file, set each unconfirmed version field to the visible placeholder `VERSION-NOT-CONFIRMED`, tell the learner in one line which versions to fill in, and skip the validate step below. Never guess a version from memory. Read the learner's Java major version from `java -version` (for example `openjdk version "21.0.4"` -> `21`; old style `1.8.0` -> `8`). If Java is not installed, use the current LTS.

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>learning</groupId>
  <artifactId>NN-<topic-slug></artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <maven.compiler.release><JAVA_MAJOR></maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version><JUNIT_VERSION></version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <artifactId>maven-surefire-plugin</artifactId>
        <version><SUREFIRE_VERSION></version>
      </plugin>
    </plugins>
  </build>
</project>
```

`NN-<topic-slug>` is the folder name (for example `05-streams`). Replace the three `<...>` placeholders with the looked-up values (or `VERSION-NOT-CONFIRMED`, see above). After writing, unless a version is unconfirmed, run `mvn -q validate` in the folder when `mvn` is installed; if it fails, show the error to the learner in one line and leave the files as they are.

## Python

Create:
- `pyproject.toml`
- `src/.gitkeep`
- `tests/.gitkeep`

Read the version from `python3 --version` (a local command, always available); any other version needed (for example a pytest pin) follows the `VERSION-NOT-CONFIRMED` rule if it cannot be confirmed (for example `Python 3.12.4` -> `>=3.12`).

```
[project]
name = "NN-<topic-slug>"
version = "0.1.0"
requires-python = ">=<MAJOR.MINOR>"

[dependency-groups]
test = ["pytest"]

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]
```

## Other technologies

Create the minimal standard setup for that tool (for example `package.json` with the standard test runner for Node, `go.mod` for Go, `Cargo.toml` for Rust, a `Dockerfile` for Docker), no source or test files. Look up current versions with WebSearch rather than from memory; any version that cannot be confirmed gets the placeholder `VERSION-NOT-CONFIRMED`, with a one-line note to the learner and no validate step. If the tool has no project setup, create the empty folder with a `.gitkeep`.
