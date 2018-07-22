package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRouter(t *testing.T) {
	// create a test server using our router
	router := MakeRouter()
	ts := httptest.NewServer(router)
	defer ts.Close()

	makeRequest := func(method string, path string, headers map[string]string, body io.Reader) *http.Request {
		req, err := http.NewRequest(method, ts.URL+path, body)
		if err != nil {
			t.Fatal(err)
		}
		if len(headers) > 0 {
			for key, value := range headers {
				req.Header.Set(key, value)
			}
		}
		return req
	}

	tests := []struct {
		name   string
		req    *http.Request
		assert func(title string, res *http.Response)
	}{
		{
			name: "with(Accept:application/json)",
			req:  makeRequest("GET", "/", map[string]string{"Accept": "application/json"}, nil),
			assert: func(title string, res *http.Response) {
				expectedContentType := "application/json; charset=utf-8"
				contentType := res.Header.Get("Content-Type")
				if contentType != expectedContentType {
					t.Error(title, "Wrong Content-Type header", "| expected:", expectedContentType, "| received:", contentType)
				}
			},
		},
		{
			name: "with(?format=json)",
			req:  makeRequest("GET", "/?format=json", nil, nil),
			assert: func(title string, res *http.Response) {
				expectedContentType := "application/json; charset=utf-8"
				contentType := res.Header.Get("Content-Type")
				if contentType != expectedContentType {
					t.Error(title, "Wrong Content-Type header", "| expected:", expectedContentType, "| received:", contentType)
				}
			},
		},
		{
			name: "with(default)",
			req:  makeRequest("GET", "/", nil, nil),
			assert: func(title string, res *http.Response) {
				expectedContentType := "text/html; charset=utf-8"
				contentType := res.Header.Get("Content-Type")
				if contentType != expectedContentType {
					t.Error(title, "Wrong Content-Type header", "| expected:", expectedContentType, "| received:", contentType)
				}
			},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			res, err := http.DefaultClient.Do(test.req)
			if err != nil {
				t.Fatal(err)
			}
			test.assert(test.name, res)
			defer res.Body.Close()
		})
	}
}
