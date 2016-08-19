//
//  Image.swift
//  DynoWall
//
//  Created by Erick Navarro on 8/18/16.
//  Copyright © 2016 Erick Navarro. All rights reserved.
//

import Foundation

struct User {
    var name = ""
    var url = ""

    var dict: NSDictionary {
        var data = [String: String]()
        data["url"] = url
        data["name"] = name
        return data
    }

    static func decode(data: NSDictionary) -> User {
        return User(name: data["name"] as! String, url: data["url"] as! String)
    }
}

struct Image {
    var url = ""
    var user = User()

    var dict: NSDictionary {
        var data = [String: AnyObject]()
        data["url"] = url
        data["user"] = user.dict
        return data
    }

    static func decode(data: NSDictionary) -> Image {
        let userData = data["user"] as! NSDictionary
        let user = User(name: userData["name"] as! String, url: userData["url"] as! String)
        return Image(url: data["url"] as! String, user: user)
    }
}