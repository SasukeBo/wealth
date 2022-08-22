package godep

import (
	_ "git.uino.com/thingyouwe-middleware/comlib/opentelemetry/otelmicro"
	_ "git.uino.com/thingyouwe-middleware/go-micro"
	_ "git.uino.com/thingyouwe-middleware/micro-plugin/utils"
	_ "git.uino.com/thingyouwe-public-proto/common-pb/common"
	_ "github.com/dgrijalva/jwt-go"
	_ "github.com/gin-gonic/gin"
	_ "github.com/go-redis/redis/v8"
	_ "github.com/go-redsync/redsync/v4"
	_ "github.com/google/uuid"
	_ "github.com/jackc/pgconn"
	_ "github.com/jinzhu/copier"
	_ "github.com/mr-tron/base58"
	_ "github.com/segmentio/ksuid"
	_ "github.com/silenceper/wechat/v2"
	_ "github.com/xuri/excelize/v2"
	_ "go.opencensus.io"
	_ "go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
	_ "go.opentelemetry.io/otel"
	_ "gorm.io/driver/postgres"
	_ "gorm.io/gorm"
)

func main() {}
