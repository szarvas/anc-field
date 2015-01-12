/*
 * Copyright 2014 Attila Szarvas
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef MJPEG_HANDLER_HPP
#define MJPEG_HANDLER_HPP

#ifndef _WIN32
#include <unistd.h>
#endif

#include "../civetweb/CivetServer.h"
#include "easylogging.hpp"

class MjpegHandler : public CivetHandler
{
public:
			MjpegHandler	() { alive_ = false; }
	bool	handleGet		(CivetServer *server, struct mg_connection *conn);
	void	SendImage		(unsigned char* image, unsigned length);
	void	Stop			() { dont_stop_ = false; }
	bool	IsConnected		() { return alive_; }

private:
	mg_connection* conn_;
	bool alive_;
	bool dont_stop_;
};

bool MjpegHandler::handleGet(CivetServer *server, struct mg_connection *conn)
{
	LOG(INFO) << "Connection received";

	mg_printf(conn, "%s",
		"HTTP/1.0 200 OK\r\n"
		"Server: StreamServer\r\n"
		"Connection: close\r\n"
		"Max-Age: 0\r\n"
		"Expires: 0\r\n"
		"Cache-Control: no-cache, private\r\n"
		"Pragma: no-cache\r\n"
		"Content-Type: multipart/x-mixed-replace;"
		"boundary=--boundarydonotcross\r\n\r\n");

	dont_stop_ = true;
	conn_ = conn;
	alive_ = true;

	while (dont_stop_)
	{
#ifdef _WIN32
		Sleep(1000);
#else
		sleep(1000);
#endif
	}

	LOG(INFO) << "Connection terminated";

	return true;
}

void MjpegHandler::SendImage(unsigned char* image, unsigned length)
{
	if (alive_)
	{
		char buf[256];
		sprintf(buf, "Content-Length: %d\r\n\r\n", length);
		mg_printf(conn_, "--boundarydonotcross\r\n");
		mg_printf(conn_, "Content-type: image/jpeg\r\n");
		mg_printf(conn_, buf);
		mg_write(conn_, (char*)image, length);
		int ret = mg_printf(conn_, "\r\n\r\n");

		if (ret == 0 || ret == -1)
		{
			dont_stop_ = false;
			alive_ = false;
		}
	}
}

#endif
