# Third-Party Licenses

This document contains the licenses for all third-party components used in AgentFoundry.

## Table of Contents

- [Python Dependencies](#python-dependencies)
- [JavaScript/Node.js Dependencies](#javascriptnodejs-dependencies)
- [Docker Base Images](#docker-base-images)
- [Development Tools](#development-tools)
- [Documentation Tools](#documentation-tools)
- [License Texts](#license-texts)

---

## Python Dependencies

### Core Framework Dependencies

#### FastAPI
- **License**: MIT License
- **Copyright**: Copyright (c) 2018 Sebastián Ramírez
- **Source**: https://github.com/tiangolo/fastapi
- **License File**: [MIT License](#mit-license)

#### Pydantic
- **License**: MIT License
- **Copyright**: Copyright (c) 2017 Samuel Colvin
- **Source**: https://github.com/pydantic/pydantic
- **License File**: [MIT License](#mit-license)

#### SQLAlchemy
- **License**: MIT License
- **Copyright**: Copyright (c) 2006-2023 the SQLAlchemy authors and contributors
- **Source**: https://github.com/sqlalchemy/sqlalchemy
- **License File**: [MIT License](#mit-license)

#### Alembic
- **License**: MIT License
- **Copyright**: Copyright (c) 2009-2023 by the Alembic authors and contributors
- **Source**: https://github.com/sqlalchemy/alembic
- **License File**: [MIT License](#mit-license)

### Database Drivers

#### psycopg2-binary
- **License**: GNU Lesser General Public License v3.0
- **Copyright**: Copyright (c) 2006-2023 Federico Di Gregorio
- **Source**: https://github.com/psycopg/psycopg2
- **License File**: [LGPL v3.0](#lgpl-v30)

#### redis
- **License**: MIT License
- **Copyright**: Copyright (c) 2012 Andy McCurdy
- **Source**: https://github.com/redis/redis-py
- **License File**: [MIT License](#mit-license)

### Authentication & Security

#### python-jose[cryptography]
- **License**: MIT License
- **Copyright**: Copyright (c) 2016 Michael Davis
- **Source**: https://github.com/mpdavis/python-jose
- **License File**: [MIT License](#mit-license)

#### passlib[bcrypt]
- **License**: BSD License
- **Copyright**: Copyright (c) 2008-2020 Assurance Technologies LLC
- **Source**: https://github.com/glic3rinu/passlib
- **License File**: [BSD License](#bsd-license)

#### cryptography
- **License**: Apache License 2.0 / BSD License
- **Copyright**: Copyright (c) Individual contributors
- **Source**: https://github.com/pyca/cryptography
- **License File**: [Apache 2.0](#apache-20) / [BSD License](#bsd-license)

### HTTP & API

#### httpx
- **License**: BSD License
- **Copyright**: Copyright (c) 2019 Tom Christie
- **Source**: https://github.com/encode/httpx
- **License File**: [BSD License](#bsd-license)

#### requests
- **License**: Apache License 2.0
- **Copyright**: Copyright (c) 2019 Kenneth Reitz
- **Source**: https://github.com/psf/requests
- **License File**: [Apache 2.0](#apache-20)

### Data Processing

#### pandas
- **License**: BSD 3-Clause License
- **Copyright**: Copyright (c) 2008-2011, AQR Capital Management, LLC, Lambda Foundry, Inc. and PyData Development Team
- **Source**: https://github.com/pandas-dev/pandas
- **License File**: [BSD 3-Clause](#bsd-3-clause)

#### numpy
- **License**: BSD 3-Clause License
- **Copyright**: Copyright (c) 2005-2023, NumPy Developers
- **Source**: https://github.com/numpy/numpy
- **License File**: [BSD 3-Clause](#bsd-3-clause)

### AI/ML Libraries

#### openai
- **License**: MIT License
- **Copyright**: Copyright (c) 2020 OpenAI
- **Source**: https://github.com/openai/openai-python
- **License File**: [MIT License](#mit-license)

#### langchain
- **License**: MIT License
- **Copyright**: Copyright (c) 2022 Harrison Chase
- **Source**: https://github.com/langchain-ai/langchain
- **License File**: [MIT License](#mit-license)

#### transformers
- **License**: Apache License 2.0
- **Copyright**: Copyright (c) 2018 The HuggingFace Inc. team
- **Source**: https://github.com/huggingface/transformers
- **License File**: [Apache 2.0](#apache-20)

### Task Queue

#### celery
- **License**: BSD License
- **Copyright**: Copyright (c) 2009-2020 by Ask Solem & contributors
- **Source**: https://github.com/celery/celery
- **License File**: [BSD License](#bsd-license)

#### flower
- **License**: BSD License
- **Copyright**: Copyright (c) 2013 Mher Movsisyan
- **Source**: https://github.com/mher/flower
- **License File**: [BSD License](#bsd-license)

### Monitoring & Observability

#### prometheus-client
- **License**: Apache License 2.0
- **Copyright**: Copyright (c) 2015 The Prometheus Authors
- **Source**: https://github.com/prometheus/client_python
- **License File**: [Apache 2.0](#apache-20)

#### opentelemetry-api
- **License**: Apache License 2.0
- **Copyright**: Copyright (c) 2019 The OpenTelemetry Authors
- **Source**: https://github.com/open-telemetry/opentelemetry-python
- **License File**: [Apache 2.0](#apache-20)

### Testing

#### pytest
- **License**: MIT License
- **Copyright**: Copyright (c) 2004-2023 Holger Krekel and others
- **Source**: https://github.com/pytest-dev/pytest
- **License File**: [MIT License](#mit-license)

#### pytest-asyncio
- **License**: Apache License 2.0
- **Copyright**: Copyright (c) 2014 Tin Tvrtković
- **Source**: https://github.com/pytest-dev/pytest-asyncio
- **License File**: [Apache 2.0](#apache-20)

---

## JavaScript/Node.js Dependencies

### Frontend Framework

#### React
- **License**: MIT License
- **Copyright**: Copyright (c) Facebook, Inc. and its affiliates
- **Source**: https://github.com/facebook/react
- **License File**: [MIT License](#mit-license)

#### Next.js
- **License**: MIT License
- **Copyright**: Copyright (c) 2016-present Vercel, Inc.
- **Source**: https://github.com/vercel/next.js
- **License File**: [MIT License](#mit-license)

### UI Components

#### Material-UI (@mui/material)
- **License**: MIT License
- **Copyright**: Copyright (c) 2014 Call-Em-All
- **Source**: https://github.com/mui/material-ui
- **License File**: [MIT License](#mit-license)

#### Tailwind CSS
- **License**: MIT License
- **Copyright**: Copyright (c) Tailwind Labs, Inc.
- **Source**: https://github.com/tailwindlabs/tailwindcss
- **License File**: [MIT License](#mit-license)

### Build Tools

#### Webpack
- **License**: MIT License
- **Copyright**: Copyright JS Foundation and other contributors
- **Source**: https://github.com/webpack/webpack
- **License File**: [MIT License](#mit-license)

#### Babel
- **License**: MIT License
- **Copyright**: Copyright (c) 2014-present Sebastian McKenzie and other contributors
- **Source**: https://github.com/babel/babel
- **License File**: [MIT License](#mit-license)

---

## Docker Base Images

### Python Base Image
- **Image**: python:3.11-slim
- **License**: Python Software Foundation License
- **Source**: https://github.com/docker-library/python
- **License File**: [PSF License](#psf-license)

### Node.js Base Image
- **Image**: node:18-alpine
- **License**: MIT License
- **Source**: https://github.com/nodejs/node
- **License File**: [MIT License](#mit-license)

### Alpine Linux
- **License**: Various (mostly MIT, BSD, GPL)
- **Source**: https://github.com/alpinelinux/aports
- **License File**: Multiple licenses apply

### PostgreSQL
- **License**: PostgreSQL License (similar to BSD)
- **Source**: https://github.com/postgres/postgres
- **License File**: [PostgreSQL License](#postgresql-license)

### Redis
- **License**: BSD 3-Clause License
- **Source**: https://github.com/redis/redis
- **License File**: [BSD 3-Clause](#bsd-3-clause)

### Nginx
- **License**: BSD 2-Clause License
- **Source**: https://github.com/nginx/nginx
- **License File**: [BSD 2-Clause](#bsd-2-clause)

---

## Development Tools

### Code Quality

#### Black
- **License**: MIT License
- **Copyright**: Copyright (c) 2018 Łukasz Langa
- **Source**: https://github.com/psf/black
- **License File**: [MIT License](#mit-license)

#### isort
- **License**: MIT License
- **Copyright**: Copyright (c) 2013 Timothy Edmund Crosley
- **Source**: https://github.com/PyCQA/isort
- **License File**: [MIT License](#mit-license)

#### flake8
- **License**: MIT License
- **Copyright**: Copyright (c) 2011-2013 Tarek Ziade
- **Source**: https://github.com/PyCQA/flake8
- **License File**: [MIT License](#mit-license)

#### mypy
- **License**: MIT License
- **Copyright**: Copyright (c) 2012-2023 Jukka Lehtosalo and contributors
- **Source**: https://github.com/python/mypy
- **License File**: [MIT License](#mit-license)

### Security Scanning

#### bandit
- **License**: Apache License 2.0
- **Copyright**: Copyright (c) 2014 Hewlett-Packard Development Company, L.P.
- **Source**: https://github.com/PyCQA/bandit
- **License File**: [Apache 2.0](#apache-20)

#### safety
- **License**: MIT License
- **Copyright**: Copyright (c) 2014 pyup.io
- **Source**: https://github.com/pyupio/safety
- **License File**: [MIT License](#mit-license)

---

## Documentation Tools

#### MkDocs
- **License**: BSD License
- **Copyright**: Copyright (c) 2014, Tom Christie
- **Source**: https://github.com/mkdocs/mkdocs
- **License File**: [BSD License](#bsd-license)

#### Material for MkDocs
- **License**: MIT License
- **Copyright**: Copyright (c) 2016-2023 Martin Donath
- **Source**: https://github.com/squidfunk/mkdocs-material
- **License File**: [MIT License](#mit-license)

---

## License Texts

### MIT License

```
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Apache 2.0

```
Apache License
Version 2.0, January 2004
http://www.apache.org/licenses/

TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

1. Definitions.

"License" shall mean the terms and conditions for use, reproduction,
and distribution as defined by Sections 1 through 9 of this document.

"Licensor" shall mean the copyright owner or entity granting the License.

"Legal Entity" shall mean the union of the acting entity and all
other entities that control, are controlled by, or are under common
control with that entity. For the purposes of this definition,
"control" means (i) the power, direct or indirect, to cause the
direction or management of such entity, whether by contract or
otherwise, or (ii) ownership of fifty percent (50%) or more of the
outstanding shares, or (iii) beneficial ownership of such entity.

"You" (or "Your") shall mean an individual or Legal Entity
exercising permissions granted by this License.

"Source" form shall mean the preferred form for making modifications,
including but not limited to software source code, documentation
source, and configuration files.

"Object" form shall mean any form resulting from mechanical
transformation or translation of a Source form, including but
not limited to compiled object code, generated documentation,
and conversions to other media types.

"Work" shall mean the work of authorship, whether in Source or
Object form, made available under the License, as indicated by a
copyright notice that is included in or attached to the work
(which shall not include communication that is conspicuously
marked or otherwise designated in writing by the copyright owner
as "Not a Contribution").

"Contribution" shall mean any work of authorship, including
the original version of the Work and any modifications or additions
to that Work or Derivative Works thereof, that is intentionally
submitted to Licensor for inclusion in the Work by the copyright owner
or by an individual or Legal Entity authorized to submit on behalf of
the copyright owner. For the purposes of this definition, "submitted"
means any form of electronic, verbal, or written communication sent
to the Licensor or its representatives, including but not limited to
communication on electronic mailing lists, source code control
systems, and issue tracking systems that are managed by, or on behalf
of, the Licensor for the purpose of discussing and improving the Work,
but excluding communication that is conspicuously marked or otherwise
designated in writing by the copyright owner as "Not a Contribution."

"Contributor" shall mean Licensor and any individual or Legal Entity
on behalf of whom a Contribution has been received by Licensor and
subsequently incorporated within the Work.

2. Grant of Copyright License. Subject to the terms and conditions of
this License, each Contributor hereby grants to You a perpetual,
worldwide, non-exclusive, no-charge, royalty-free, irrevocable
copyright license to use, reproduce, modify, display, perform,
sublicense, and distribute the Work and such Derivative Works in
Source or Object form.

3. Grant of Patent License. Subject to the terms and conditions of
this License, each Contributor hereby grants to You a perpetual,
worldwide, non-exclusive, no-charge, royalty-free, irrevocable
(except as stated in this section) patent license to make, have made,
use, offer to sell, sell, import, and otherwise transfer the Work,
where such license applies only to those patent claims licensable
by such Contributor that are necessarily infringed by their
Contribution(s) alone or by combination of their Contribution(s)
with the Work to which such Contribution(s) was submitted. If You
institute patent litigation against any entity (including a
cross-claim or counterclaim in a lawsuit) alleging that the Work
or a Contribution incorporated within the Work constitutes direct
or contributory patent infringement, then any patent licenses
granted to You under this License for that Work shall terminate
as of the date such litigation is filed.

4. Redistribution. You may reproduce and distribute copies of the
Work or Derivative Works thereof in any medium, with or without
modifications, and in Source or Object form, provided that You
meet the following conditions:

(a) You must give any other recipients of the Work or
    Derivative Works a copy of this License; and

(b) You must cause any modified files to carry prominent notices
    stating that You changed the files; and

(c) You must retain, in the Source form of any Derivative Works
    that You distribute, all copyright, trademark, patent,
    attribution and disclaimer notices from the Source form
    of the Work, excluding those notices that do not pertain to
    any part of the Derivative Works; and

(d) If the Work includes a "NOTICE" text file as part of its
    distribution, then any Derivative Works that You distribute must
    include a readable copy of the attribution notices contained
    within such NOTICE file, excluding those notices that do not
    pertain to any part of the Derivative Works, in at least one
    of the following places: within a NOTICE text file distributed
    as part of the Derivative Works; within the Source form or
    documentation, if provided along with the Derivative Works; or,
    within a display generated by the Derivative Works, if and
    wherever such third-party notices normally appear. The contents
    of the NOTICE file are for informational purposes only and
    do not modify the License. You may add Your own attribution
    notices within Derivative Works that You distribute, alongside
    or as an addendum to the NOTICE text from the Work, provided
    that such additional attribution notices cannot be construed
    as modifying the License.

You may add Your own copyright notice to Your modifications and
may provide additional or different license terms and conditions
for use, reproduction, or distribution of Your modifications, or
for any such Derivative Works as a whole, provided Your use,
reproduction, and distribution of the Work otherwise complies with
the conditions stated in this License.

5. Submission of Contributions. Unless You explicitly state otherwise,
any Contribution intentionally submitted for inclusion in the Work
by You to the Licensor shall be under the terms and conditions of
this License, without any additional terms or conditions.
Notwithstanding the above, nothing herein shall supersede or modify
the terms of any separate license agreement you may have executed
with Licensor regarding such Contributions.

6. Trademarks. This License does not grant permission to use the trade
names, trademarks, service marks, or product names of the Licensor,
except as required for reasonable and customary use in describing the
origin of the Work and reproducing the content of the NOTICE file.

7. Disclaimer of Warranty. Unless required by applicable law or
agreed to in writing, Licensor provides the Work (and each
Contributor provides its Contributions) on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied, including, without limitation, any warranties or conditions
of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
PARTICULAR PURPOSE. You are solely responsible for determining the
appropriateness of using or redistributing the Work and assume any
risks associated with Your exercise of permissions under this License.

8. Limitation of Liability. In no event and under no legal theory,
whether in tort (including negligence), contract, or otherwise,
unless required by applicable law (such as deliberate and grossly
negligent acts) or agreed to in writing, shall any Contributor be
liable to You for damages, including any direct, indirect, special,
incidental, or consequential damages of any character arising as a
result of this License or out of the use or inability to use the
Work (including but not limited to damages for loss of goodwill,
work stoppage, computer failure or malfunction, or any and all
other commercial damages or losses), even if such Contributor
has been advised of the possibility of such damages.

9. Accepting Warranty or Additional Liability. When redistributing
the Work or Derivative Works thereof, You may choose to offer,
and charge a fee for, acceptance of support, warranty, indemnity,
or other liability obligations and/or rights consistent with this
License. However, in accepting such obligations, You may act only
on Your own behalf and on Your sole responsibility, not on behalf
of any other Contributor, and only if You agree to indemnify,
defend, and hold each Contributor harmless for any liability
incurred by, or claims asserted against, such Contributor by reason
of your accepting any such warranty or additional liability.

END OF TERMS AND CONDITIONS
```

### BSD 3-Clause

```
BSD 3-Clause License

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

### BSD 2-Clause

```
BSD 2-Clause License

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

### BSD License

```
BSD License

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of the University nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
```

### LGPL v3.0

```
GNU LESSER GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.

This version of the GNU Lesser General Public License incorporates
the terms and conditions of version 3 of the GNU General Public
License, supplemented by the additional permissions listed below.

0. Additional Definitions.

As used herein, "this License" refers to version 3 of the GNU Lesser
General Public License, and the "GNU GPL" refers to version 3 of the GNU
General Public License.

"The Library" refers to a covered work governed by this License,
other than an Application or a Combined Work as defined below.

"Application" means any work that makes use of an interface provided
by the Library, but which is not otherwise based on the Library.
Defining a subclass of a class defined by the Library is deemed a mode
of using an interface provided by the Library.

"Combined Work" means a work produced by combining or linking an
Application with the Library.  The particular version of the Library
with which the Combined Work was made is also called the "Linked
Version".

"Minimal Corresponding Source" for a Combined Work means the
Corresponding Source for the Combined Work, excluding any source code
for portions of the Combined Work that, considered in isolation, are
based on the Application, and not on the Linked Version.

"Corresponding Application Code" for a Combined Work means the
object code and/or source code for the Application, including any data
and utility programs needed for reproducing the Combined Work from the
Application, but excluding the System Libraries of the Combined Work.

1. Exception to Section 3 of the GNU GPL.

You may convey a covered work under sections 3 and 4 of this License
without being bound by section 3 of the GNU GPL.

2. Conveying Library Source.

You may convey a copy of the Library's complete source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Library.

You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

[Additional sections continue...]
```

### PostgreSQL License

```
PostgreSQL License

Copyright (c) PostgreSQL Global Development Group

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose, without fee, and without a written agreement
is hereby granted, provided that the above copyright notice and this
paragraph and the following two paragraphs appear in all copies.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO
PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
```

### PSF License

```
Python Software Foundation License

1. This LICENSE AGREEMENT is between the Python Software Foundation
("PSF"), and the Individual or Organization ("Licensee") accessing and
otherwise using this software ("Python") in source or binary form and
its associated documentation.

2. Subject to the terms and conditions of this License Agreement, PSF hereby
grants Licensee a nonexclusive, royalty-free, world-wide license to reproduce,
analyze, test, perform and/or display publicly, prepare derivative works,
distribute, and otherwise use Python alone or in any derivative version,
provided, however, that PSF's License Agreement and PSF's notice of copyright,
i.e., "Copyright (c) 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023 Python
Software Foundation; All Rights Reserved" are retained in Python alone or in any
derivative version prepared by Licensee.

3. In the event Licensee prepares a derivative work that is based on
or incorporates Python or any part thereof, and wants to make
the derivative work available to others as provided herein, then
Licensee hereby agrees to include in any such work a brief summary of
the changes made to Python.

4. PSF is making Python available to Licensee on an "AS IS"
basis.  PSF MAKES NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR
IMPLIED.  BY WAY OF EXAMPLE, BUT NOT LIMITATION, PSF MAKES NO AND
DISCLAIMS ANY REPRESENTATION OR WARRANTY OF MERCHANTABILITY OR FITNESS
FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF PYTHON WILL NOT
INFRINGE ANY THIRD PARTY RIGHTS.

5. PSF SHALL NOT BE LIABLE TO LICENSEE OR ANY OTHER USERS OF PYTHON
FOR ANY INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES OR LOSS AS
A RESULT OF MODIFYING, DISTRIBUTING, OR OTHERWISE USING PYTHON,
OR ANY DERIVATIVE THEREOF, EVEN IF ADVISED OF THE POSSIBILITY THEREOF.

6. This License Agreement will automatically terminate upon a material
breach of its terms and conditions.

7. Nothing in this License Agreement shall be deemed to create any
relationship of agency, partnership, or joint venture between PSF and
Licensee.  This License Agreement does not grant permission to use PSF
trademarks or trade name in a trademark sense to endorse or promote
products or services of Licensee, or any third party.

8. By copying, installing or otherwise using Python, Licensee
agrees to be bound by the terms and conditions of this License
Agreement.
```

---

## License Compliance Notes

### Attribution Requirements

When using AgentFoundry in your projects, please ensure you comply with the attribution requirements of the included third-party components:

1. **MIT Licensed Components**: Include copyright notices in your distribution
2. **Apache 2.0 Licensed Components**: Include NOTICE files and copyright notices
3. **BSD Licensed Components**: Include copyright notices and disclaimers
4. **GPL/LGPL Components**: Ensure source code availability requirements are met

### Redistribution Guidelines

- Include this `THIRD_PARTY_LICENSES.md` file in any redistribution
- Maintain all copyright notices and license texts
- Provide source code for GPL/LGPL licensed components when required
- Include any required NOTICE files from Apache 2.0 licensed components

### Commercial Use

Most components included in AgentFoundry are permissive licenses (MIT, Apache 2.0, BSD) that allow commercial use. However:

- Review individual license terms for specific requirements
- Some components may have additional commercial licensing options
- Ensure compliance with copyleft licenses (GPL/LGPL) if applicable

### Updates and Maintenance

This file is updated regularly to reflect changes in dependencies. For the most current information:

- Check the project's dependency files (`requirements.txt`, `package.json`)
- Review individual component licenses for updates
- Monitor security advisories for included components

---

**Last Updated**: January 2024  
**Maintained By**: AgentFoundry Legal Team  
**Contact**: [legal@agentfoundry.dev](mailto:legal@agentfoundry.dev)

For questions about third-party licenses or compliance requirements, please contact our legal team.