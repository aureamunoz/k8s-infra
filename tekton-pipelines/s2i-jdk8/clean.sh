#!/usr/bin/env bash


kubectl delete taskrun.tekton.dev/s2i-springboot-example
kubectl delete taskrun.tekton.dev/s2i-buildah-springboot
kubectl delete taskrun.tekton.dev/s2i-buildah-push-springboot

kubectl delete task.tekton.dev/s2i-jdk8
kubectl delete task.tekton.dev/s2i-jdk8-push
kubectl delete task.tekton.dev/s2i-buildah
kubectl delete task.tekton.dev/s2i-buildah-push

kubectl delete secret/basic-user-pass
kubectl delete sa/build-bot
