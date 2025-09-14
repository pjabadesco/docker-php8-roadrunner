## OLD

docker-compose build
docker build -t pjabadesco/php8-roadrunner:0.1 .

## NEW

docker buildx build --platform=linux/amd64 --build-arg LEGACY_TLS=true --tag=php8-roadrunner:latest --load .

docker tag php8-roadrunner:latest pjabadesco/php8-roadrunner:0.1
docker push pjabadesco/php8-roadrunner:0.1

docker tag pjabadesco/php8-roadrunner:0.1 pjabadesco/php8-roadrunner:latest
docker push pjabadesco/php8-roadrunner:latest

docker tag pjabadesco/php8-roadrunner:latest ghcr.io/pjabadesco/php8-roadrunner:latest
docker push ghcr.io/pjabadesco/php8-roadrunner:latest

# Build normally

docker run -it --rm -p 8080:80 -v ./www:/var/www/html/ php8-roadrunner:latest
docker run --rm -p 8080:80 php8-roadrunner:latest
curl <http://localhost:8080/health>
