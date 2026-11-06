{{/*
Expand the name of the chart.
*/}}
{{- define "sar-mel-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "sar-mel-backend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart labels
*/}}
{{- define "sar-mel-backend.labels" -}}
helm.sh/chart: {{ include "sar-mel-backend.chart" . }}
{{ include "sar-mel-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: sar-mel
{{- end }}

{{- define "sar-mel-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sar-mel-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sar-mel-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Service account name
*/}}
{{- define "sar-mel-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sar-mel-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Secret name
*/}}
{{- define "sar-mel-backend.secretName" -}}
{{- if .Values.existingSecret }}
{{- .Values.existingSecret }}
{{- else }}
{{- include "sar-mel-backend.fullname" . }}
{{- end }}
{{- end }}

{{/*
Image reference
*/}}
{{- define "sar-mel-backend.image" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Database URL
*/}}
{{- define "sar-mel-backend.databaseUrl" -}}
{{- if .Values.database.url }}
{{- .Values.database.url }}
{{- else }}
{{- $user := .Values.database.user }}
{{- $pass := .Values.secret.postgresPassword }}
{{- $db := .Values.database.name }}
{{- $host := .Values.database.host }}
{{- $port := .Values.database.port }}
{{- printf "postgresql://%s:%s@%s:%v/%s" $user $pass $host $port $db }}
{{- end }}
{{- end }}
