#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
today=`date +%Y-%m-%d`
read -p "Post link?" subject
read -p "Post title?" title
filename="${dir}/_posts/${today}-${subject}".md
layout="---
layout: post
title: ${title}
---
"
echo "${layout}" > ${filename}
open ${filename}



