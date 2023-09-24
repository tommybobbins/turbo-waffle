# turbo-waffle
AWS s3-mount terraform example, based on
https://github.com/awslabs/mountpoint-s3

Finding an Ubuntu images
```
aws ec2 describe-images --filters "Name=name,Values=ubuntu*" --query "sort_by(Images, &CreationDate)[].[Name, ImageId]" --region=eu-west-2
```
