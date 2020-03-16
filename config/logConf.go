package config

import (
	"github.com/spf13/viper"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
	"os"
)

// Initialization log
func (c *Config) initLog() error {

	encoderConfig := zapcore.EncoderConfig{
		TimeKey:        viper.GetString("zap.EncoderConfig.TimeKey"),
		LevelKey:       viper.GetString("zap.EncoderConfig.LevelKey"),
		NameKey:        viper.GetString("zap.EncoderConfig.NameKey"),
		CallerKey:      viper.GetString("zap.EncoderConfig.CallerKey"),
		MessageKey:     viper.GetString("zap.EncoderConfig.MessageKey"),
		StacktraceKey:  viper.GetString("zap.EncoderConfig.StacktraceKey"),
		LineEnding:     zapcore.DefaultLineEnding,
		EncodeLevel:    zapcore.LowercaseLevelEncoder, // lowercase encoder
		EncodeTime:     zapcore.ISO8601TimeEncoder,    // ISO8601 UTC time
		EncodeDuration: zapcore.SecondsDurationEncoder,
		EncodeCaller:   zapcore.FullCallerEncoder, // full path encoder
	}

	atomicLevel := zap.NewAtomicLevelAt(filterZapAtomicLevelByViper()) // log Level

	rotateLogger := lumberjack.Logger{
		Filename:   viper.GetString("zap.rotate.Filename"), // Log file path
		MaxSize:    viper.GetInt("zap.rotate.MaxSize"),     // Maximum size of each log file Unit: M
		MaxBackups: viper.GetInt("zap.rotate.MaxBackups"),  // How many backups are saved in the log file
		MaxAge:     viper.GetInt("zap.rotate.MaxAge"),      // How many days can the file be keep
		Compress:   viper.GetBool("zap.rotate.Compress"),   // need compress
	}

	core := zapcore.NewCore(
		zapcore.NewJSONEncoder(encoderConfig), // Encoder configuration
		zapcore.NewMultiWriteSyncer(
			zapcore.AddSync(os.Stdout),
			zapcore.AddSync(&rotateLogger),
		), // Print to console and file
		atomicLevel, // Log level
	)

	filed := zap.Fields(zap.String(viper.GetString("zap.Fields.Key"), viper.GetString("zap.Fields.Val"))) //the initialization fieldv
	var logZap *zap.Logger
	if viper.GetBool("zap.AddCaller") {
		if viper.GetBool("zap.Development") { // Open file and line number
			logZap = zap.New(core, zap.AddCaller(), zap.Development(), filed)
		} else {
			logZap = zap.New(core, zap.AddCaller(), filed)
		}
	} else {
		if viper.GetBool("zap.Development") { // Open file and line number
			logZap = zap.New(core, zap.AddCaller(), zap.Development(), filed)
		} else {
			logZap = zap.New(core, zap.AddCaller(), filed)
		}
	}
	logZap.Debug("log init success")

	baseConf.Log = logZap
	baseConf.Sugar = logZap.Sugar()

	//passLagerCfg := log.PassLagerCfg{
	//	Writers:        viper.GetString("log.writers"),
	//	LoggerLevel:    viper.GetString("log.logger_level"),
	//	LoggerFile:     viper.GetString("log.logger_file"),
	//	LogFormatText:  viper.GetBool("log.log_format_text"),
	//	RollingPolicy:  viper.GetString("log.rollingPolicy"),
	//	LogRotateDate:  viper.GetInt("log.log_rotate_date"),
	//	LogRotateSize:  viper.GetInt("log.log_rotate_size"),
	//	LogBackupCount: viper.GetInt("log.log_backup_count"),
	//}
	//err := log.InitWithConfig(&passLagerCfg)
	return nil
}

func filterZapAtomicLevelByViper() zapcore.Level {
	var atomViper zapcore.Level
	switch viper.GetInt("zap.AtomicLevel") {
	default:
		atomViper = zap.InfoLevel
	case -1:
		atomViper = zap.DebugLevel
	case 0:
		atomViper = zap.InfoLevel
	case 1:
		atomViper = zap.WarnLevel
	case 2:
		atomViper = zap.ErrorLevel
	}
	return atomViper
}
