#	openSteam - http://www.opensteam.net
#  Copyright (C) 2009  DiamondDogs Webconsulting
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


module Opensteam
  
  
  # Security Module (Encryption, etc)
  # (not in use right now) 
  module Security #:nodoc:
    
    
    module Encryption
      
      mattr_accessor :algorithm
      
      self.algorithm = 'aes-256-cbc'
      
      def encrypt( data, password, salt )
        cipher = OpenSSL::Cipher::Cipher.new algorithm
        cipher.encrypt
        cipher.pkcs5_keyivgen( password, salt )
        encrypted_data = cipher.update( data )
        encrypted_data << cipher.final
      end
      
      
      def decrypt( encrypted_data, password, salt )
        cipher = OpenSSL::Cipher::Cipher.new( algorithm )
        cipher.decrypt
        cipher.pkcs5_keyivgen( password, salt )
        data = cipher.update( encrypted_data )
        data << cipher.final
      end
      
      
    end
    
    
  end
end