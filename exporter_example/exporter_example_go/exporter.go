package main

import (
	"log"
	"net/http"

	"github.com/pbnjay/memory"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func memoriaLivre() float64 {
	memoria_livre := memory.FreeMemory()
	return float64(memoria_livre)
}
func totalMemoria() float64 {
	memoria_total := memory.TotalMemory()
	return float64(memoria_total)
}

var (
	memoriaLivreBytesGauge = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "memoria_livre_bytes",
		Help: "Quantidade de memória livre em bytes",
	})
	memoriaLivreMegasGauge = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "memoria_livre_megas",
		Help: "Quantidade de memória livre em megas",
	})
	TotalMemoryBytesGauge = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "total_memoria_bytes",
		Help: "Quantidade total de memória em bytes",
	})
	TotalMemoryGigasGauge = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "total_memoria_gigas",
		Help: "Quantidade total de memória em gigas",
	})
)

func init() {
	prometheus.MustRegister(memoriaLivreBytesGauge)
	prometheus.MustRegister(memoriaLivreMegasGauge)
	prometheus.MustRegister(TotalMemoryBytesGauge)
	prometheus.MustRegister(TotalMemoryGigasGauge)
}
func main() {
	memoriaLivreBytesGauge.Set(memoriaLivre())
	memoriaLivreMegasGauge.Set(memoriaLivre() / (1024 ^ 2))
	TotalMemoryBytesGauge.Set(totalMemoria())
	TotalMemoryGigasGauge.Set(totalMemoria() / (1024 ^ 3))
	http.Handle("/metrics", promhttp.Handler())
	log.Fatal(http.ListenAndServe(":7788", nil))

}
