#!/bin/bash

function image_exists() {
    docker images -q $1
}