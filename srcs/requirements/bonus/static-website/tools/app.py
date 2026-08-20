import http.server
import socketserver

PORT = 8080

handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("", PORT), handler) as httpd:
    print(f"server start on port{PORT}\n \
            acess http://localhost:{PORT}\n \
            Press Ctl + c to stop the server")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped")
