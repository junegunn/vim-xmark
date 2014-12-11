/*
Copyright (c) 2014 Junegunn Choi

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include <ApplicationServices/ApplicationServices.h>
#include <iostream>
#include <sstream>
#include <cstdio>

const char* command =
  "osascript -e 'tell application \"System Events\"\n"
  "  set active_app to first application process whose frontmost is true\n"
  "  set {x, y} to position of window 1 of active_app\n"
  "  x as string & \" \" & y as string\n"
  "end tell'";

std::string exec(const char* cmd) {
  FILE* pipe = popen(cmd, "r");
  if (!pipe) return "";

  char buf[128];
  std::ostringstream ss;
  while (!feof(pipe) && fgets(buf, sizeof(buf), pipe) != NULL)
    ss << buf;
  pclose(pipe);
  return ss.str();
}

int main(int argc, const char** argv) {
  std::istringstream ss(exec(command));
  double x, y;
  ss >> x;
  ss >> y;
  CGPoint point = { .x = CGFloat(x), .y = CGFloat(y) };

  CGDirectDisplayID displays[10];
  uint32_t matches;
  CGGetDisplaysWithPoint(point, sizeof(displays), displays, &matches);
  CGDirectDisplayID display = matches == 0 ? CGMainDisplayID() : displays[0];

  CGRect bound = CGDisplayBounds(display);
  std::cout << bound.origin.x   << " " << bound.origin.y << " "
            << bound.size.width << " " << bound.size.height << std::endl;
  return 0;
}

