import { FastifyError, FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';

interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
  meta: {
    timestamp: string;
    requestId?: string;
  };
}

export function errorHandler(
  error: FastifyError,
  request: FastifyRequest,
  reply: FastifyReply
): void {
  const response: ErrorResponse = {
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
    },
    meta: {
      timestamp: new Date().toISOString(),
      requestId: request.id,
    },
  };

  // Zod validation errors
  if (error instanceof ZodError) {
    response.error.code = 'VALIDATION_ERROR';
    response.error.message = 'Validation failed';
    response.error.details = error.flatten().fieldErrors;
    reply.status(400).send(response);
    return;
  }

  // Fastify validation errors
  if (error.validation) {
    response.error.code = 'VALIDATION_ERROR';
    response.error.message = error.message;
    response.error.details = error.validation;
    reply.status(400).send(response);
    return;
  }

  // Not found
  if (error.statusCode === 404) {
    response.error.code = 'NOT_FOUND';
    response.error.message = error.message || 'Resource not found';
    reply.status(404).send(response);
    return;
  }

  // Unauthorized
  if (error.statusCode === 401) {
    response.error.code = 'UNAUTHORIZED';
    response.error.message = error.message || 'Authentication required';
    reply.status(401).send(response);
    return;
  }

  // Forbidden
  if (error.statusCode === 403) {
    response.error.code = 'FORBIDDEN';
    response.error.message = error.message || 'Access denied';
    reply.status(403).send(response);
    return;
  }

  // Rate limit exceeded
  if (error.statusCode === 429) {
    response.error.code = 'RATE_LIMIT_EXCEEDED';
    response.error.message = 'Too many requests, please try again later';
    reply.status(429).send(response);
    return;
  }

  // Log unexpected errors
  request.log.error(error);

  // Default 500 error
  const statusCode = error.statusCode || 500;
  if (statusCode >= 500) {
    response.error.code = 'INTERNAL_ERROR';
    response.error.message =
      process.env.NODE_ENV === 'development' ? error.message : 'Internal server error';
  } else {
    response.error.code = 'BAD_REQUEST';
    response.error.message = error.message;
  }

  reply.status(statusCode).send(response);
}
