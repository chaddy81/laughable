$aws = Aws.config.update({ region: 'us-west-2', credentials: Aws::Credentials.new(ENV['PURGATORY_AWS_ACCESS_KEY_ID'], ENV['PURGATORY_AWS_SECRET_ACCESS_KEY'])})

$s3 = Aws::S3::Resource.new(region: 'us-east-1')
