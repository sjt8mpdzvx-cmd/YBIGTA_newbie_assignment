
# anaconda(또는 miniconda)가 존재하지 않을 경우 설치해주세요!
## TODO
if ! command -v conda >/dev/null 2>&1; then
  echo "[INFO] conda 없음 → miniconda 설치"

  OS="$(uname -s)"
  ARCH="$(uname -m)"

  if [ "$OS" = "Darwin" ] && [ "$ARCH" = "arm64" ]; then
    INSTALLER="Miniconda3-latest-MacOSX-arm64.sh"
  elif [ "$OS" = "Darwin" ] && [ "$ARCH" = "x86_64" ]; then
    INSTALLER="Miniconda3-latest-MacOSX-x86_64.sh"
  elif [ "$OS" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
    INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
  elif [ "$OS" = "Linux" ] && { [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; }; then
    INSTALLER="Miniconda3-latest-Linux-aarch64.sh"
  else
    echo "[INFO] 지원하지 않는 OS/ARCH: $OS / $ARCH"
    exit 1
  fi

  curl -L -o /tmp/miniconda.sh "https://repo.anaconda.com/miniconda/$INSTALLER"
  bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
  rm -f /tmp/miniconda.sh
  export PATH="$HOME/miniconda3/bin:$PATH"
fi

source "$(conda info --base)/etc/profile.d/conda.sh"


# Conda 환셩 생성 및 활성화
## TODO
if ! conda env list | awk '{print $1}' | grep -qx "myenv"; then
  conda create -y -n myenv python=3.11
fi
conda activate myenv

## 건드리지 마세요! ##
python_env=$(python -c "import sys; print(sys.prefix)")
if [[ "$python_env" == *"/envs/myenv"* ]]; then
    echo "[INFO] 가상환경 활성화: 성공"
else
    echo "[INFO] 가상환경 활성화: 실패"
    exit 1 
fi

# 필요한 패키지 설치
## TODO
python -m pip -q install --upgrade pip
python -m pip -q install mypy
mkdir -p ../output

# Submission 폴더 파일 실행
cd submission || { echo "[INFO] submission 디렉토리로 이동 실패"; exit 1; }

for file in *.py; do
    ## TODO
    prob="${file##*_}"
    prob="${prob%.py}"
    in_file="../input/${prob}_input"
    out_file="../output/${prob}_output"

    if [ ! -f "$in_file" ]; then
      echo "[INFO] 입력 파일 없음: $in_file"
      exit 1
    fi

    python "$file" < "$in_file" > "$out_file"
    echo "[INFO] 실행 완료: $file -> $out_file"

done

# mypy 테스트 실행 및 mypy_log.txt 저장
## TODO
mypy *.py > ../mypy_log.txt 2>&1
echo "[INFO] mypy 실행 완료 (실패여도 진행)"


# conda.yml 파일 생성
## TODO
conda env export --name myenv --no-builds > ../conda.yml

# 가상환경 비활성화
## TODO
conda deactivate

