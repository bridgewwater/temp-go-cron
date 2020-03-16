package config

import (
	"github.com/spf13/viper"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
	"os"
)

var zapLog zapLogger

type zapLogger struct {
	Log   *zap.Logger
	Sugar *zap.SugaredLogger
}

func Sugar() *zap.SugaredLogger {
	return zapLog.Sugar
}

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
		EncodeLevel:    zapcore.CapitalColorLevelEncoder, // or LowercaseLevelEncoder lowercase encoder
		EncodeTime:     zapcore.ISO8601TimeEncoder,       // ISO8601TimeEncoder ISO8601 UTC time
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

	encoder := filterZapEncoder(encoderConfig)

	core := zapcore.NewCore(
		encoder, // Encoder configuration
		zapcore.NewMultiWriteSyncer(
			zapcore.AddSync(os.Stdout),
			zapcore.AddSync(&rotateLogger),
		), // Print to console and file
		atomicLevel, // Log level
	)
	var filed zap.Option
	if viper.GetBool("zap.FieldsAuto") {
		filed = zap.Fields( //the initialization field
			zap.String(viper.GetString("zap.Fields.Key"), viper.GetString("zap.Fields.Val")),
		)
	}

	var logZap *zap.Logger
	if viper.GetBool("zap.Development") {
		if filed != nil {
			logZap = zap.New(core, zap.AddCaller(), zap.Development(), filed)
		} else {
			logZap = zap.New(core, zap.AddCaller(), zap.Development())
		}
	} else {
		if filed != nil {
			logZap = zap.New(core, filed)
		} else {
			logZap = zap.New(core)
		}
	}

	logZap.Warn("zap log init success")
	zapLog = zapLogger{
		Log:   logZap,
		Sugar: logZap.Sugar(),
	}
	return nil
}

func filterZapEncoder(encoderConfig zapcore.EncoderConfig) zapcore.Encoder {
	var encoder zapcore.Encoder
	zapEncoding := viper.GetString("zap.Encoding")
	switch zapEncoding {
	default:
		encoder = zapcore.NewConsoleEncoder(encoderConfig)
	case "json":
		encoder = zapcore.NewJSONEncoder(encoderConfig)
	case "console":
		encoder = zapcore.NewConsoleEncoder(encoderConfig)
	}
	return encoder
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
