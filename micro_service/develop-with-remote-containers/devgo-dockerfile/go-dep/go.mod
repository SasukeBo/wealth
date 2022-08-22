module godep

go 1.16

require (
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/gin-gonic/gin v1.8.1
	github.com/go-redis/redis/v8 v8.11.6-0.20220405070650-99c79f7041fc
	github.com/go-redsync/redsync/v4 v4.5.0
	github.com/gomodule/redigo v1.8.5 // indirect
	github.com/google/uuid v1.3.0
	github.com/jackc/pgconn v1.10.1
	github.com/jinzhu/copier v0.3.5
	github.com/mr-tron/base58 v1.2.0
	github.com/segmentio/ksuid v1.0.4
	github.com/silenceper/wechat/v2 v2.1.3
	github.com/xuri/excelize/v2 v2.4.1
	go.opencensus.io v0.23.0
	go.opentelemetry.io/otel v1.7.0
	gorm.io/driver/postgres v1.3.1
	gorm.io/gorm v1.23.8
)

require go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin v0.32.0

require (
	git.uino.com/thingyouwe-middleware/comlib/opentelemetry v0.1.0
	git.uino.com/thingyouwe-middleware/go-micro v1.1.4
	git.uino.com/thingyouwe-middleware/micro-plugin v1.1.5
	git.uino.com/thingyouwe-public-proto/common-pb v1.1.1
)
