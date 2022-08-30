# 목적
오클 앱 필요기능 연습 레포지토리 

# 브랜치 규칙
- exercise : 해당 브랜치에서 각 연습기능별로 브랜치 생성 후 exercise로 merge 

## Trouble Shooting

```
swift
    // 이거하면 왜 URL이 nil로 리턴 안됨? https://stackoverflow.com/questions/48576329/ios-urlstring-not-working-always
    init?(_ string: String) {
        guard string.isEmpty == false else {
            return nil
        }
        if let url = URL(string: string) {
            self = url
        } else if let urlEscapedString = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
                  let escapedURL = URL(string: urlEscapedString) {
            self = escapedURL
        } else {
            return nil
        }
    }
```

### Reference
1. login
- appl login
    - https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms

    - https://www.youtube.com/watch?v=vuygdr0EcGM
