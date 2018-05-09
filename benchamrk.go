package main
import "fmt"
import "time"
import "github.com/tsenart/vegeta/lib"

func testRate(rate int, sla time.Duration) bool {
	duration := 15 * time.Second
	targeter := vegeta.NewStaticTargeter(vegeta.Target{
		Method: "GET",
		URL:    "http://localhost:8755/",
	})
	attacker := vegeta.NewAttacker()
	var metrics vegeta.Metrics
	for res := range attacker.Attack(targeter, uint64(rate), duration) {
		metrics.Add(res)
	}
	metrics.Close()
	latency := metrics.Latencies.P95
	if latency > sla {
		fmt.Printf("💥  Failed at %d req/sec (latency %s)\n", rate, latency)
		return false
	}
	fmt.Printf("✨  Success at %d req/sec (latency %s)\n", rate, latency)
	return true
}

func main() {
  testRate(2,2)
}
