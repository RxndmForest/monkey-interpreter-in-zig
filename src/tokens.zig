const std = @import("std");

pub fn main() !void {}

pub const Token = struct { type: TokenType, literal: []const u8 };

// union with switch function to accomplish similar thing in go?
pub const TokenType = enum {
    ILLEGAL,
    EOF,
    IDENT,
    STRING,
    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,
    SLASH,
    LT,
    GT,
    EQ,
    NOT_EQ,
    COMMA,
    SEMICOLON,
    COLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    LBRACKET,
    RBRACKET,
    FUNCTION,
    LET,
    TRUE,
    FALSE,
    IF,
    ELSE,
    RETURN,

    fn token(self: TokenType) []const u8 {
        return switch (self) {
            TokenType.ILLEGAL => "ILLEGAL",
            TokenType.EOF => "EOF",
            TokenType.IDENT => "IDENT",
            TokenType.STRING => "STRING",
            TokenType.ASSIGN => "=",
            TokenType.PLUS => "+",
            TokenType.MINUS => "-",
            TokenType.BANG => "!",
            TokenType.ASTERISK => "*",
            TokenType.SLASH => "/",
            TokenType.LT => "<",
            TokenType.GT => ">",
            TokenType.EQ => "==",
            TokenType.NOT_EQ => "!=",
            TokenType.COMMA => ",",
            TokenType.SEMICOLON => ";",
            TokenType.COLON => ":",
            TokenType.LPAREN => "(",
            TokenType.RPAREN => ")",
            TokenType.LBRACE => "{",
            TokenType.RBRACE => "}",
            TokenType.LBRACKET => "[",
            TokenType.RBRACKET => "]",
            TokenType.FUNCTION => "FUNCTION",
            TokenType.LET => "LET",
            TokenType.TRUE => "TRUE",
            TokenType.FALSE => "FALSE",
            TokenType.IF => "IF",
            TokenType.ELSE => "ELSE",
            TokenType.RETURN => "RETURN",
        };
    }
};

pub const keywords = std.ComptimeStringMap(TokenType, .{
    .{ "fn", .FUNCTION },
    .{ "let", .LET },
    .{ "true", .TRUE },
    .{ "false", .FALSE },
    .{ "if", .IF },
    .{ "else", .ELSE },
    .{ "return", .RETURN },
});

//func LookupIdent(ident string) TokenType{
//  if tok, ok := keywords[ident]; ok {
//      return tok
//  }
//  return IDENT
//}

pub fn LookupIdent(ident: []const u8) ?TokenType {
    return keywords.get(ident);
}

test "union method" {
    try std.testing.expect(@TypeOf(TokenType.MINUS.token()) == []const u8);
}

test "accessing hashmap" {
    try std.testing.expectEqual(TokenType.FUNCTION, keywords.get("fn") orelse unreachable);
}

test "lookup function" {
    try std.testing.expectEqual(TokenType.FUNCTION, LookupIdent("fn") orelse unreachable);
}
