package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func helloWorld(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprint(w, "<h1>Hello World</h1>")
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/", helloWorld)
	log.Fatal(http.ListenAndServe(":5000", router))
}
