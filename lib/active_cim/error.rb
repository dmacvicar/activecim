module ActiveCim
  # Base class for ActiveCim errors
  class Error < RuntimeError; end
  
  # A general error occurred that is not covered by a more specific error code
  class ErrorFailed < ActiveCim::Error; end
  # Access to a CIM resource was not available to the client
  class ErrorAccessDenied < ActiveCim::Error; end
  # The target namespace does not exist
  class ErrorInvalidNamespace < ActiveCim::Error; end
  # One or more parameter values passed to the method were invalid
  class ErrorInvalidParameter < ActiveCim::Error; end
  # The specified Class does not exist
  class ErrorInvalidClass < ActiveCim::Error; end
  # The requested object could not be found
  class ErrorNotFound < ActiveCim::Error; end
  # The requested operation is not supported
  class ErrorNotSupported < ActiveCim::Error; end
  # Operation cannot be carried out on this class since it has subclasses
  class ErrorClassHasChildren < ActiveCim::Error; end
  # Operation cannot be carried out on this class since it has instances
  class ErrorClassHasInstances < ActiveCim::Error; end
  # Operation cannot be carried out since the specified superclass does not exist
  class ErrorInvalidSuperClass < ActiveCim::Error; end
  # Operation cannot be carried out because an object already exists
  class ErrorAlreadyExists < ActiveCim::Error; end
  # The specified Property does not exist
  class ErrorNoSuchProperty < ActiveCim::Error; end
  # The value supplied is incompatible with the type
  class ErrorTypeMisMatch < ActiveCim::Error; end
  # The query language is not recognized or supported
  class ErrorQueryLanguageNotSupported < ActiveCim::Error; end
  # The query is not valid for the specified query language
  class ErrorInvalidQuery < ActiveCim::Error; end
  # The extrinsic Method could not be executed
  class ErrorMethodNotAvailable < ActiveCim::Error; end
  # The specified extrinsic Method does not exist
  class ErrorMethodNotFound < ActiveCim::Error; end
end
