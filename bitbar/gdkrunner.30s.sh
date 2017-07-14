#!/bin/bash
number=$(curl -s http://localhost:9402/debug/jobs/list | wc -l);
echo "${number} ◉";
echo "---";
curl -s http://localhost:9402/metrics | grep ^ci_runner_builds
