package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"

	"github.com/gorilla/mux"
)

var startTime time.Time

func uptime() float64 {
	return time.Since(startTime).Seconds()
}

type infos struct {
	Hostname string  `json:"hostname"`
	Version  string  `json:"version"`
	Cpus     int     `json:"cpus"`
	AppEnv   string  `json:"APP_ENV"`
	Uptime   float64 `json:"uptime"`
}

func makeInfos() *infos {
	hostname, err := os.Hostname()
	if err != nil {
		hostname = "Unknown"
	}
	return &infos{hostname, runtime.Version(), runtime.NumCPU(), os.Getenv("APP_ENV"), uptime()}
}

func rootRouteHTML(w http.ResponseWriter, _ *http.Request) {
	infos := makeInfos()
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprintf(w, `<h1>Welcome</h1>
	<ul>
		<li>Hostname: %s</li>
		<li>Version: %s</li>
		<li>Number of CPUs: %d</li>
		<li>APP_ENV: %s</li>
	</ul>`, infos.Hostname, infos.Version, infos.Cpus, infos.AppEnv)
}

func rootRouteJSON(w http.ResponseWriter, r *http.Request) {
	infos := makeInfos()
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(infos)
}

// only here to demonstrate the resilience of containers restarted on failure by docker-compose/kubernetes
// DON'T DO THAT ON PRODUCTION
func exitRoute(w http.ResponseWriter, r *http.Request) {
	os.Exit(1)
}

// MakeRouter Public router factory - this is unit tested
func MakeRouter() *mux.Router {
	router := mux.NewRouter()
	router.HandleFunc("/", rootRouteJSON).Methods("GET").HeadersRegexp("Accept", "application/json")
	router.HandleFunc("/", rootRouteJSON).Methods("GET").Queries("format", "json")
	router.HandleFunc("/", rootRouteHTML).Methods("GET")
	router.HandleFunc("/exit", exitRoute).Methods("GET")
	return router
}

func init() {
	startTime = time.Now()
}

func main() {
	router := MakeRouter()
	log.Fatal(http.ListenAndServe(":5000", router))
}
