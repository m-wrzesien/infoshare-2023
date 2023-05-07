package main

import (
	"embed"
	"flag"
	"io"
	"net/http"

	"cloud.google.com/go/compute/metadata"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/template/html"
	"github.com/rs/zerolog/log"
)

const BindAddress = ":8080"

type TemplateData struct {
	ClusterName string
	ReleaseName string
}

var releaseName = flag.String("releaseName", "", "Name of Helm Release for this app")

//go:embed templates/*
var templatesFiles embed.FS

func getClusterName() (string, error) {
	cluster, err := metadata.InstanceAttributeValue("cluster-name")
	if err != nil {
		return "", err
	}
	return cluster, nil
}

func main() {
	flag.Parse()

	engine := html.NewFileSystem(http.FS(templatesFiles), ".html")
	app := fiber.New(fiber.Config{
		DisableStartupMessage: true,
		Views:                 engine,
	})

	app.Use(logger.New(logger.Config{
		Done: func(c *fiber.Ctx, logString []byte) {
			log.Debug().RawJSON("request", logString).Send()
		},
		Format: "{\"status\": \"${status}\", \"latency\": \"${latency}\", \"method\": \"${method}\", \"path\": \"${path}\"}",
		Output: io.Discard,
	}))

	app.Get("/", func(c *fiber.Ctx) error {
		cn, err := getClusterName()

		if err != nil {
			log.Warn().Err(err).Send()
		}

		td := TemplateData{
			ClusterName: cn,
			ReleaseName: *releaseName,
		}

		return c.Render("templates/index", td)
	})

	app.Get("/_healthz", func(c *fiber.Ctx) error {
		return c.SendString("Stayin' alive ♫")
	})

	log.Info().Msgf("App is ready for serving requests on %s", BindAddress)
	log.Fatal().Err(app.Listen(BindAddress)).Send()
}
