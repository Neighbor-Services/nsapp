import re

file_path = 'e:/ns/frontend/nsapp/lib/features/provider/data/repository/provider_repository_impl.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the null checks
content = re.sub(r'if\s*\(results\s*!=\s*null\)\s*\{\s*return\s+Right\(results\);\s*\}\s*return\s+Left\(ErrorHandler\.handle\(e\)\);', r'return Right(results);', content)
content = re.sub(r'if\s*\(results\s*!=\s*null\)\s*\{([\s\S]*?)\}\s*return\s+Left\(ErrorHandler\.handle\(e\)\);', r'\1', content)

# But wait, earlier I replaced generic error with ErrorHandler.handle(e) for the catch block. 
# The actual structure of the code inside the try block is:
# if (results != null) { ... return Right(results); } return Left(Failure(message: "An error occurred"));
# But the python script replaced "An error occurred" with ErrorHandler.handle(e) EVERYWHERE.
# So the code is currently:
# if (results != null) { ... return Right(results); } return Left(ErrorHandler.handle(e));

content = re.sub(r'if\s*\(results\s*!=\s*null\)\s*\{\s*(.*?)\s*\}\s*return\s+Left\(ErrorHandler\.handle\(e\)\);', r'\1', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Updated provider repository null checks')
