package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"

	"github.com/curvegrid/gofig"
	echo "github.com/labstack/echo/v4"
	middleware "github.com/labstack/echo/v4/middleware"
)

type Config struct {
	StorageToken string
}

var config Config

// ReverseProxyHandler returns an Echo Handler function that acts as a simple HTTP reverse proxy.
func ReverseProxyHandler(target *url.URL) echo.HandlerFunc {
	return func(c echo.Context) (err error) {
		req := c.Request()
		res := c.Response()

		// Workaround https://github.com/golang/go/issues/28168
		req.Host = target.Host

		proxy := httputil.NewSingleHostReverseProxy(target)
		proxy.ErrorHandler = func(res http.ResponseWriter, req *http.Request, e error) {
			err = echo.NewHTTPError(http.StatusBadGateway, fmt.Sprintf("remote %s unreachable, could not forward: %v", target, e))
		}

		// replace the authorization header in the request
		req.Header.Del("Authorization")
		req.Header.Add("Authorization", "Bearer "+config.StorageToken)

		fmt.Printf("Uploaded a file from %v\n", req.RemoteAddr)

		proxy.ServeHTTP(res, req)
		return
	}
}

func main() {
	gofig.SetEnvPrefix("NFTJR")
	gofig.Parse(&config)

	e := echo.New()

	// static file server
	e.Use(middleware.StaticWithConfig(middleware.StaticConfig{
		Root:   "../frontend/dist",
		Browse: false,
		HTML5:  true,
		Index:  "index.html",
	}))

	// reverse proxy for nft.storage
	uploadTarget, err := url.Parse("https://nft.storage/api")
	if err != nil {
		panic(err)
	}
	e.POST("/upload", ReverseProxyHandler(uploadTarget))

	// start serving
	e.Logger.Fatal(e.Start(":8090"))
}
