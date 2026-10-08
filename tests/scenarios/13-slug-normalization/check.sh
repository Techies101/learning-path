#!/usr/bin/env bash
set -e
[ "$(ls learning | wc -l)" = 2 ]
[ -f learning/index.md ]
[ -f learning/spring-boot/roadmap.md ]
[ ! -e "learning/Spring Boot" ]
